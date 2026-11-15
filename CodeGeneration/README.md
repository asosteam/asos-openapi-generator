# asos-codegen

The OpenAPI code generator behind this repository. It ships a single generator, **`swiftASOS`**, which produces
Swift models following ASOS conventions. For day-to-day usage see the [root README](../README.md); this document
covers building and changing the generator.

The project is a Maven multi-module build producing `asos-codegen-cli.jar`, which supports the usual
`generate`, `batch`, `config-help`, `list` and `validate` commands.

## Layout

| Path | Purpose |
| --- | --- |
| `modules/asos-codegen-core` | Core generator API |
| `modules/asos-codegen` | Generation engine, the `swiftASOS` generator and its Mustache templates |
| `modules/asos-codegen-cli` | Command line interface, builds `asos-codegen-cli.jar` |
| `modules/asos-codegen/src/main/java/com/asos/codegen/languages/SwiftASOSClientCodegen.java` | The generator |
| `modules/asos-codegen/src/main/resources/swiftASOS/` | Templates |
| `modules/asos-codegen/src/main/java/com/asos/codegen/OpenAPINormalizer.java` | Spec normalizer; includes the `REMOVE_UNUSED_SCHEMAS` rule used for per-endpoint generation |
| `modules/asos-codegen/src/test/java/com/asos/codegen/` | Unit tests (`swiftASOS/` for the generator) |
| `scripts/codegen-tool.sh` | Builds the jar and runs the generator for one contract (models only) |
| `bin/configs/` | Sample configurations, used by `bin/generate-samples.sh` |
| `samples/client/petstore/swiftASOS/` | Generated samples (source-controlled; regenerate after generator changes) |

## Requirements

- Java 11 (`brew install openjdk@11`)
- Maven is provided through the wrapper (`./mvnw`)
- Swift 5.9+ / Xcode to build the generated samples

## Build and test

```sh
./mvnw clean package                                   # build everything, run tests
./mvnw -pl modules/asos-codegen test                   # tests only
```

## Run the generator

```sh
java -jar modules/asos-codegen-cli/target/asos-codegen-cli.jar generate -g swiftASOS -i path/to/openapi.yaml -o out
java -jar modules/asos-codegen-cli/target/asos-codegen-cli.jar config-help -g swiftASOS   # all options
```

Or through the wrapper script, which builds the jar first unless `--ignore-build` is passed and generates models only:

```sh
sh scripts/codegen-tool.sh -i path/to/openapi.yaml -o out
```

Options: `-o` output folder, `-g` generator, `-t` template directory, `-n` OpenAPI normalizer rules
(e.g. `FILTER=operationId:getPet,REMOVE_UNUSED_SCHEMAS=true`), `--public-memberwise-init`, `--ignore-build`.

## Working on the generator

After changing `SwiftASOSClientCodegen.java` or the templates:

1. `./mvnw clean package`
2. Regenerate the samples and commit the result:
   ```sh
   ./bin/generate-samples.sh
   ```
3. Verify a sample compiles: `cd samples/client/petstore/swiftASOS/default && swift build`

## License

Apache 2.0, see [LICENSE](LICENSE).
