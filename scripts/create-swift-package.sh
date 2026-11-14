#!/bin/sh
#
# Generates a Swift Package containing the API models of an OpenAPI contract.
#
# The contract can be a local YAML file or a remote URL. Models are generated
# with codegen-tool.sh (swiftASOS generator, models only) and wrapped in a
# package with one library product, a main target and an empty test target.

set -u

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
CODEGEN_TOOL="$SCRIPT_DIR/codegen-tool.sh"

INPUT=""
OUTPUT=""
PACKAGE_NAME=""
IGNORE_BUILD=false
PUBLIC_MEMBERWISE_INIT=false
SKIP_SWIFT_BUILD=false

usage() {
    cat <<EOF
Usage: sh create-swift-package.sh <input> <output> [options]

Arguments:
  input                     Path or URL of the OpenAPI YAML contract
  output                    Directory in which the Swift Package is created

Options:
  --name <Name>             Package name (default: CamelCase of the contract file name,
                            e.g. customer-loyalty-v1 -> CustomerLoyaltyV1)
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

# ── Arguments ─────────────────────────────────────────────────────────────────

while [ $# -gt 0 ]; do
    case "$1" in
        --name) shift; [ $# -gt 0 ] || usage; PACKAGE_NAME="$1" ;;
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

# ── Generate the models ───────────────────────────────────────────────────────

echo "Generating models for '$API_NAME' with the swiftASOS generator ..."
GEN_DIR="$WORK_DIR/gen"
set -- -i "$CONTRACT" -o "$GEN_DIR"
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

echo "Creating Swift Package '$PACKAGE_NAME' in $PACKAGE_DIR ..."
# Generated sources are replaced wholesale; existing tests are left untouched.
rm -rf "$SOURCES_DIR"
mkdir -p "$SOURCES_DIR" "$TESTS_DIR"
cp "$MODELS_DIR"/*.swift "$SOURCES_DIR"/

cat > "$PACKAGE_DIR/Package.swift" <<EOF
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

COPIED_COUNT=$(find "Sources/$PACKAGE_NAME" -name '*.swift' | wc -l | tr -d ' ')
[ "$COPIED_COUNT" -eq "$MODEL_COUNT" ] || fail "Expected $MODEL_COUNT model files in Sources/$PACKAGE_NAME, found $COPIED_COUNT"

TEST_FILE_COUNT=$(find "Tests/$TEST_TARGET_NAME" -type f | wc -l | tr -d ' ')

# The manifest is the source of truth for products/targets: SwiftPM drops the
# source-less test target from the resolved graph that `describe` reports.
MANIFEST=$($SWIFT package dump-package 2>/dev/null) || fail "swift package dump-package failed; Package.swift is invalid"
PRODUCT_COUNT=$(printf '%s' "$MANIFEST" | grep -c '"library" *:')
REGULAR_TARGET_COUNT=$(printf '%s' "$MANIFEST" | grep -c '"type" *: *"regular"')
TEST_TARGET_COUNT=$(printf '%s' "$MANIFEST" | grep -c '"type" *: *"test"')
TARGET_COUNT=$((REGULAR_TARGET_COUNT + TEST_TARGET_COUNT))
[ "$PRODUCT_COUNT" -eq 1 ] || fail "Expected 1 library product, found $PRODUCT_COUNT"
[ "$TARGET_COUNT" -eq 2 ] || fail "Expected 2 targets, found $TARGET_COUNT"
[ "$TEST_TARGET_COUNT" -eq 1 ] || fail "Expected 1 test target, found $TEST_TARGET_COUNT"

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

Swift Package created successfully.
  Package:       $PACKAGE_DIR
  Contract:      $CONTRACT_NAME
  Swift tools:   $SWIFT_TOOLS_VERSION ($SWIFT_VERSION toolchain via '$SWIFT')
  Models:        $MODEL_COUNT file(s) in Sources/$PACKAGE_NAME
  Products:      $PRODUCT_COUNT library ($PACKAGE_NAME)
  Targets:       $TARGET_COUNT ($PACKAGE_NAME, $TEST_TARGET_NAME)
  Test sources:  $TEST_FILE_COUNT file(s)
EOF
[ "$SKIP_SWIFT_BUILD" = false ] && echo "  Build:         OK"
exit 0
