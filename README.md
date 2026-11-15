# ASOS Code Generation

Generates Swift API models from OpenAPI contracts, following ASOS conventions. The generator is a trimmed,
single-generator (`swiftASOS`) build of an OpenAPI code generator; the scripts in this repository wrap it so
that a contract can be turned into a Swift Package (or a folder of model files) with one command.

## Repository layout

| Path | Contents |
| --- | --- |
| [scripts/generate.sh](scripts/generate.sh) | Entry point: contract in, Swift Package or model files out |
| [CodeGeneration/](CodeGeneration/) | The code generator (`asos-codegen`, Maven multi-module Java project) |
| [CodeGeneration/scripts/codegen-tool.sh](CodeGeneration/scripts/codegen-tool.sh) | Low-level wrapper: builds the generator and runs it for one contract |
| [CodeGeneration/README.md](CodeGeneration/README.md) | How to build, test and change the generator itself |

## Prerequisites

- macOS with Xcode (used for `swift build` / `swift package`)
- Java 11: `brew install openjdk@11` (the scripts find the Homebrew install automatically)
- `curl` for remote contracts

Maven is provided by the wrapper in `CodeGeneration/mvnw`; nothing else needs installing.

## Usage

```sh
sh scripts/generate.sh --input <contract> --output <directory> [--mode package|models] [--name <Name>] [--endpoint]
```

| Argument | Description |
| --- | --- |
| `--input <contract>` | **Required.** Path or URL of the OpenAPI YAML contract. `~` is expanded; `http(s)://` URLs are downloaded. |
| `--output <directory>` | **Required.** Directory in which the result is created (created if missing). |
| `--mode package` | Default. Creates or updates a Swift Package at `<output>/<Name>/`. |
| `--mode models` | Exports the generated model files to `<output>/<Name>/` with no package around them. |
| `--name <Name>` | Package / folder name. Default: the contract file name in CamelCase (`customer-loyalty-v1.yaml` → `CustomerLoyaltyV1`). |
| `--endpoint` | Lists the contract's endpoints, asks which one to use and generates only the models that endpoint needs. |
| `--help` | Shows the usage. |

Every run builds the generator from source, generates the models and finally removes all build output
from `CodeGeneration/` (Maven `target/` folders) and the temporary files, so the repository is left clean.

### Examples

Create a Swift Package on the Desktop from a local contract:

```sh
sh scripts/generate.sh --input ~/Desktop/customer-loyalty-v1.yaml --output ~/Desktop
```

```
~/Desktop/CustomerLoyaltyV1/
├── Package.swift                      # swift-tools-version matches the installed toolchain
├── Sources/CustomerLoyaltyV1/         # generated models
└── Tests/CustomerLoyaltyV1Tests/      # empty, ready for tests
```

Export only the model files from a remote contract, under a custom name:

```sh
sh scripts/generate.sh --input https://host/api/openapi.yaml --output ./Generated --mode models --name MyAPI
```

Generate the models of a single endpoint:

```sh
sh scripts/generate.sh --input ~/Desktop/customer-loyalty-v1.yaml --output ~/Desktop --endpoint
```

```
Endpoints in customer-loyalty-v1.yaml:
   1) GET    /customer/loyalty/v1/healthcheck  - Assess the health of the loyalty API
   2) GET    /customer/loyalty/v1/config  - Get the configuration for the loyalty service.
   ...
Select an endpoint [1-6]: 2
```

### What the script does

1. Resolves the contract (local file or download) and derives the name.
2. With `--endpoint`, lists the operations under `paths:` in contract order and asks for a choice. The chosen
   `operationId` is passed to the generator as `FILTER=operationId:<id>,REMOVE_UNUSED_SCHEMAS=true`, which keeps
   only that operation and the schemas reachable from it. Endpoints must have an `operationId`.
3. Runs `codegen-tool.sh`, which builds `asos-codegen-cli.jar` and generates **models only** with the `swiftASOS`
   generator.
4. `package` mode: creates the package (one library product, `<Name>` and `<Name>Tests` targets) and validates it
   with `swift package dump-package`, `swift package describe` and `swift build`.
   `models` mode: copies the `.swift` files to `<output>/<Name>/`.
5. Cleans up the generator build output.

### Re-running on an existing output

- The model files are replaced; in `package` mode `Package.swift` and `Tests/` are never modified, so manual edits
  and tests survive regeneration.
- A full run (no `--endpoint`) replaces the model files wholesale, so schemas removed from the contract disappear.
- An `--endpoint` run adds or overwrites only that endpoint's models and keeps the others, so the models of
  several endpoints can be accumulated over successive runs.
- The same input and selection always produce identical files.

## Running the generator directly

`CodeGeneration/scripts/codegen-tool.sh` is what `generate.sh` calls. It can be used on its own when more control
is needed (other output locations, templates, normalizer rules, public memberwise initialisers):

```sh
sh CodeGeneration/scripts/codegen-tool.sh -i path/to/openapi.yaml -o out [--ignore-build] [--public-memberwise-init] [-n <normalizer rules>] [-t <template dir>]
```

See `sh CodeGeneration/scripts/codegen-tool.sh --help` for all options, and
[CodeGeneration/README.md](CodeGeneration/README.md) for working on the generator and its templates.

## License

Apache 2.0, see [CodeGeneration/LICENSE](CodeGeneration/LICENSE).
