#!/bin/sh
#
# Generates a Swift Package containing the API models of an OpenAPI contract.
#
# The contract can be a local YAML file or a remote URL. Models are generated
# with codegen-tool.sh (swiftASOS generator, models only) and wrapped in a
# package with one library product, a main target and an empty test target.
#
# When the package already exists only the model files are replaced; Package.swift
# and Tests/ are left untouched. With --endpoint a single operation is chosen
# interactively and only the models it uses are generated (added to / overwriting
# the existing model files, so endpoints can be accumulated over several runs).

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
CODEGEN_TOOL="$SCRIPT_DIR/codegen-tool.sh"

INPUT=""
OUTPUT=""
PACKAGE_NAME=""
IGNORE_BUILD=false
PUBLIC_MEMBERWISE_INIT=false
SKIP_SWIFT_BUILD=false
ENDPOINT_MODE=false

usage() {
    cat <<EOF
Usage: sh create-swift-package.sh <input> <output> [options]

Arguments:
  input                     Path or URL of the OpenAPI YAML contract
  output                    Directory in which the Swift Package is created

Options:
  --name <Name>             Package name (default: CamelCase of the contract file name,
                            e.g. customer-loyalty-v1 -> CustomerLoyaltyV1)
  --endpoint                Interactively pick one endpoint of the contract and generate
                            only the models it uses (default: all models)
  --public-memberwise-init  Generate public memberwise initialisers for the models
  --ignore-build            Do not rebuild the code generator before generating
  --skip-swift-build        Create the package but do not compile it
  --help                    Display this help message

Example:
  sh create-swift-package.sh ~/Desktop/customer-loyalty-v1.yaml ~/Desktop
EOF
    exit "${1:-1}"
}

fail() {
    echo "Error: $*" >&2
    exit 1
}

expand_tilde() {
    case "$1" in
        "~") echo "$HOME" ;;
        "~/"*) echo "$HOME${1#\~}" ;;
        *) echo "$1" ;;
    esac
}

is_url() {
    case "$1" in
        http://*|https://*) return 0 ;;
        *) return 1 ;;
    esac
}

# customer-loyalty-v1 -> CustomerLoyaltyV1
camel_case() {
    printf '%s' "$1" | awk -F'[^A-Za-z0-9]+' '{
        out = ""
        for (i = 1; i <= NF; i++) {
            if ($i != "") out = out toupper(substr($i, 1, 1)) substr($i, 2)
        }
        if (out ~ /^[0-9]/) out = "_" out
        print out
    }'
}

# Lists the operations of an OpenAPI YAML document, in contract order, one per line:
#   METHOD<TAB>/path<TAB>operationId<TAB>summary
list_endpoints() {
    awk '
        function flush() {
            if (method != "") printf "%s\t%s\t%s\t%s\n", toupper(method), path, opid, summary
            method = ""; opid = ""; summary = ""
        }
        function unquote(v) { sub(/^[ \t]+/, "", v); sub(/[ \t]+$/, "", v); gsub(/^["'"'"']|["'"'"']$/, "", v); return v }
        /^paths:[ \t]*$/ { in_paths = 1; next }
        in_paths && /^[^ \t#]/ { flush(); in_paths = 0 }
        !in_paths { next }
        /^  [^ \t#][^:]*:[ \t]*$/ { flush(); path = $0; sub(/^  /, "", path); sub(/:[ \t]*$/, "", path); path = unquote(path); next }
        /^    (get|put|post|delete|options|head|patch|trace):[ \t]*$/ { flush(); method = $1; sub(/:.*/, "", method); next }
        method != "" && /^      operationId[ \t]*:/ { v = $0; sub(/^[^:]*:/, "", v); opid = unquote(v); next }
        method != "" && /^      summary[ \t]*:/ { v = $0; sub(/^[^:]*:/, "", v); summary = unquote(v); next }
        END { flush() }
    ' "$1"
}

# ── Arguments ─────────────────────────────────────────────────────────────────

while [ $# -gt 0 ]; do
    case "$1" in
        --name) shift; [ $# -gt 0 ] || usage; PACKAGE_NAME="$1" ;;
        --endpoint) ENDPOINT_MODE=true ;;
        --public-memberwise-init) PUBLIC_MEMBERWISE_INIT=true ;;
        --ignore-build) IGNORE_BUILD=true ;;
        --skip-swift-build) SKIP_SWIFT_BUILD=true ;;
        --help|-h) usage 0 ;;
        -*) echo "Unknown option: $1" >&2; usage ;;
        *)
            if [ -z "$INPUT" ]; then INPUT="$1"
            elif [ -z "$OUTPUT" ]; then OUTPUT="$1"
            else echo "Unexpected argument: $1" >&2; usage
            fi
            ;;
    esac
    shift
done

[ -n "$INPUT" ] || { echo "Missing <input>" >&2; usage; }
[ -n "$OUTPUT" ] || { echo "Missing <output>" >&2; usage; }
[ -f "$CODEGEN_TOOL" ] || fail "codegen-tool.sh not found next to this script ($CODEGEN_TOOL)"

INPUT=$(expand_tilde "$INPUT")
OUTPUT=$(expand_tilde "$OUTPUT")

# ── Swift toolchain ───────────────────────────────────────────────────────────

# Prefer the Xcode toolchain on macOS: standalone toolchains on PATH may not match the installed SDK.
if command -v xcrun >/dev/null 2>&1 && xcrun --find swift >/dev/null 2>&1; then
    SWIFT="xcrun swift"
elif command -v swift >/dev/null 2>&1; then
    SWIFT="swift"
else
    fail "Swift toolchain not found. Install Xcode or a Swift toolchain."
fi

SWIFT_VERSION=$($SWIFT --version 2>&1 | sed -n 's/.*Swift version \([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p' | head -1)
[ -n "$SWIFT_VERSION" ] || fail "Unable to determine the Swift version from '$SWIFT --version'"
SWIFT_TOOLS_VERSION="$SWIFT_VERSION"

# ── Working directory ─────────────────────────────────────────────────────────

WORK_DIR=$(mktemp -d "${TMPDIR:-/tmp}/create-swift-package.XXXXXX") || fail "Unable to create a temporary directory"
trap 'rm -rf "$WORK_DIR"' EXIT INT TERM

# ── Resolve the contract ──────────────────────────────────────────────────────

if is_url "$INPUT"; then
    CONTRACT_NAME=$(basename "${INPUT%%\?*}")
    CONTRACT="$WORK_DIR/$CONTRACT_NAME"
    echo "Downloading contract from $INPUT ..."
    curl -fsSL --retry 2 --connect-timeout 15 -o "$CONTRACT" "$INPUT" \
        || fail "Unable to download the contract from $INPUT"
    [ -s "$CONTRACT" ] || fail "Downloaded contract is empty: $INPUT"
else
    [ -e "$INPUT" ] || fail "Contract not found: $INPUT"
    [ -f "$INPUT" ] || fail "Contract is not a file: $INPUT"
    [ -r "$INPUT" ] || fail "Contract is not readable: $INPUT"
    CONTRACT=$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")
    CONTRACT_NAME=$(basename "$CONTRACT")
fi

API_NAME="${CONTRACT_NAME%.*}"
[ -n "$PACKAGE_NAME" ] || PACKAGE_NAME=$(camel_case "$API_NAME")
[ -n "$PACKAGE_NAME" ] || fail "Unable to derive a package name from '$CONTRACT_NAME'; use --name"
TEST_TARGET_NAME="${PACKAGE_NAME}Tests"

# ── Endpoint selection ────────────────────────────────────────────────────────

SELECTED_ENDPOINT=""
NORMALIZER_RULES=""
if [ "$ENDPOINT_MODE" = true ]; then
    ENDPOINTS_FILE="$WORK_DIR/endpoints"
    list_endpoints "$CONTRACT" > "$ENDPOINTS_FILE"
    ENDPOINT_COUNT=$(wc -l < "$ENDPOINTS_FILE" | tr -d ' ')
    [ "$ENDPOINT_COUNT" -gt 0 ] || fail "No endpoints found under 'paths:' in $CONTRACT_NAME"
    [ -r /dev/tty ] && [ -w /dev/tty ] || fail "--endpoint needs an interactive terminal to select the endpoint"

    {
        echo
        echo "Endpoints in $CONTRACT_NAME:"
        awk -F'\t' '{ printf "  %2d) %-6s %s", NR, $1, $2; if ($4 != "") printf "  - %s", $4; printf "\n" }' "$ENDPOINTS_FILE"
        echo
    } > /dev/tty

    while :; do
        printf 'Select an endpoint [1-%s]: ' "$ENDPOINT_COUNT" > /dev/tty
        read -r CHOICE < /dev/tty || fail "No endpoint selected"
        case "$CHOICE" in
            *[!0-9]*|"") ;;
            *) [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "$ENDPOINT_COUNT" ] && break ;;
        esac
        echo "Please enter a number between 1 and $ENDPOINT_COUNT." > /dev/tty
    done

    SELECTED_LINE=$(sed -n "${CHOICE}p" "$ENDPOINTS_FILE")
    SELECTED_METHOD=$(printf '%s' "$SELECTED_LINE" | cut -f1)
    SELECTED_PATH=$(printf '%s' "$SELECTED_LINE" | cut -f2)
    SELECTED_OPERATION_ID=$(printf '%s' "$SELECTED_LINE" | cut -f3)
    SELECTED_ENDPOINT="$SELECTED_METHOD $SELECTED_PATH"
    [ -n "$SELECTED_OPERATION_ID" ] || fail "Endpoint '$SELECTED_ENDPOINT' has no operationId in the contract; add one to generate its models in isolation"
    case "$SELECTED_OPERATION_ID" in
        *[!A-Za-z0-9_.-]*) fail "operationId '$SELECTED_OPERATION_ID' contains characters that cannot be passed to the generator filter" ;;
    esac
    # FILTER keeps only this operation; REMOVE_UNUSED_SCHEMAS drops every schema it does not reach.
    NORMALIZER_RULES="FILTER=operationId:$SELECTED_OPERATION_ID,REMOVE_UNUSED_SCHEMAS=true"
    echo "Selected: $SELECTED_ENDPOINT ($SELECTED_OPERATION_ID)"
fi

# ── Generate the models ───────────────────────────────────────────────────────

if [ "$ENDPOINT_MODE" = true ]; then
    echo "Generating models for '$SELECTED_ENDPOINT' with the swiftASOS generator ..."
else
    echo "Generating models for '$API_NAME' with the swiftASOS generator ..."
fi
GEN_DIR="$WORK_DIR/gen"
set -- -i "$CONTRACT" -o "$GEN_DIR"
[ -n "$NORMALIZER_RULES" ] && set -- "$@" -n "$NORMALIZER_RULES"
[ "$IGNORE_BUILD" = true ] && set -- "$@" --ignore-build
[ "$PUBLIC_MEMBERWISE_INIT" = true ] && set -- "$@" --public-memberwise-init
sh "$CODEGEN_TOOL" "$@" || fail "Model generation failed (see output above)"

MODELS_DIR=$(find "$GEN_DIR" -type d -name Models | head -1)
[ -n "$MODELS_DIR" ] || fail "No Models directory produced by the generator"
MODEL_COUNT=$(find "$MODELS_DIR" -name '*.swift' | wc -l | tr -d ' ')
[ "$MODEL_COUNT" -gt 0 ] || fail "No model files were generated from $CONTRACT_NAME"

# ── Create the package ────────────────────────────────────────────────────────

mkdir -p "$OUTPUT" || fail "Unable to create output directory $OUTPUT"
OUTPUT=$(cd "$OUTPUT" && pwd)
PACKAGE_DIR="$OUTPUT/$PACKAGE_NAME"
SOURCES_DIR="$PACKAGE_DIR/Sources/$PACKAGE_NAME"
TESTS_DIR="$PACKAGE_DIR/Tests/$TEST_TARGET_NAME"

if [ -f "$PACKAGE_DIR/Package.swift" ]; then
    PACKAGE_EXISTS=true
    echo "Updating existing Swift Package '$PACKAGE_NAME' in $PACKAGE_DIR (Package.swift and Tests/ are kept) ..."
else
    PACKAGE_EXISTS=false
    echo "Creating Swift Package '$PACKAGE_NAME' in $PACKAGE_DIR ..."
fi

if [ "$ENDPOINT_MODE" = true ]; then
    # Only this endpoint's models are added or overwritten; models of other endpoints stay.
    mkdir -p "$SOURCES_DIR" "$TESTS_DIR"
else
    # Full generation replaces the model files wholesale so removed schemas disappear.
    rm -rf "$SOURCES_DIR"
    mkdir -p "$SOURCES_DIR" "$TESTS_DIR"
fi
cp "$MODELS_DIR"/*.swift "$SOURCES_DIR"/

[ "$PACKAGE_EXISTS" = false ] && cat > "$PACKAGE_DIR/Package.swift" <<EOF
// swift-tools-version: $SWIFT_TOOLS_VERSION

import PackageDescription

let package = Package(
    name: "$PACKAGE_NAME",
    products: [
        .library(
            name: "$PACKAGE_NAME",
            targets: ["$PACKAGE_NAME"]
        ),
    ],
    targets: [
        .target(
            name: "$PACKAGE_NAME"
        ),
        .testTarget(
            name: "$TEST_TARGET_NAME",
            dependencies: ["$PACKAGE_NAME"]
        ),
    ]
)
EOF

# ── Validate ──────────────────────────────────────────────────────────────────

echo "Validating package ..."
cd "$PACKAGE_DIR" || fail "Unable to enter $PACKAGE_DIR"

SOURCE_COUNT=$(find "Sources/$PACKAGE_NAME" -name '*.swift' | wc -l | tr -d ' ')
for f in "$MODELS_DIR"/*.swift; do
    cmp -s "$f" "Sources/$PACKAGE_NAME/$(basename "$f")" || fail "Generated model $(basename "$f") was not copied into Sources/$PACKAGE_NAME"
done
if [ "$ENDPOINT_MODE" = false ] && [ "$SOURCE_COUNT" -ne "$MODEL_COUNT" ]; then
    fail "Expected $MODEL_COUNT model files in Sources/$PACKAGE_NAME, found $SOURCE_COUNT"
fi

TEST_FILE_COUNT=$(find "Tests/$TEST_TARGET_NAME" -type f | wc -l | tr -d ' ')

# The manifest is the source of truth for products/targets: SwiftPM drops the
# source-less test target from the resolved graph that `describe` reports.
MANIFEST=$($SWIFT package dump-package 2>/dev/null) || fail "swift package dump-package failed; Package.swift is invalid"
PRODUCT_COUNT=$(printf '%s' "$MANIFEST" | grep -c '"library" *:')
REGULAR_TARGET_COUNT=$(printf '%s' "$MANIFEST" | grep -c '"type" *: *"regular"')
TEST_TARGET_COUNT=$(printf '%s' "$MANIFEST" | grep -c '"type" *: *"test"')
TARGET_COUNT=$((REGULAR_TARGET_COUNT + TEST_TARGET_COUNT))
if [ "$PACKAGE_EXISTS" = false ]; then
    [ "$PRODUCT_COUNT" -eq 1 ] || fail "Expected 1 library product, found $PRODUCT_COUNT"
    [ "$TARGET_COUNT" -eq 2 ] || fail "Expected 2 targets, found $TARGET_COUNT"
    [ "$TEST_TARGET_COUNT" -eq 1 ] || fail "Expected 1 test target, found $TEST_TARGET_COUNT"
else
    # An existing manifest may have been customised; only require the models target to still be declared.
    printf '%s' "$MANIFEST" | grep -q "\"name\" *: *\"$PACKAGE_NAME\"" || fail "Existing Package.swift no longer declares a target named $PACKAGE_NAME"
fi

echo
echo "swift package describe:"
# The warning about the empty test target is expected until tests are added.
$SWIFT package describe 2>&1 | grep -v "Source files for target $TEST_TARGET_NAME should be located" | sed 's/^/  /'
echo

if [ "$SKIP_SWIFT_BUILD" = false ]; then
    echo "Building package ..."
    BUILD_LOG="$WORK_DIR/swift-build.log"
    if ! $SWIFT build >"$BUILD_LOG" 2>&1; then
        grep -E "error:" "$BUILD_LOG" | grep -v '^ *|' >&2
        fail "swift build failed. Full log:
$(cat "$BUILD_LOG")"
    fi
    rm -rf .build
fi

cat <<EOF

Swift Package $([ "$PACKAGE_EXISTS" = true ] && echo updated || echo created) successfully.
  Package:       $PACKAGE_DIR
  Contract:      $CONTRACT_NAME
  Scope:         ${SELECTED_ENDPOINT:-all endpoints}
  Swift tools:   $SWIFT_TOOLS_VERSION ($SWIFT_VERSION toolchain via '$SWIFT')
  Models:        $MODEL_COUNT generated, $SOURCE_COUNT file(s) in Sources/$PACKAGE_NAME
  Products:      $PRODUCT_COUNT library
  Targets:       $TARGET_COUNT
  Test sources:  $TEST_FILE_COUNT file(s)
EOF
[ "$SKIP_SWIFT_BUILD" = false ] && echo "  Build:         OK"
exit 0
