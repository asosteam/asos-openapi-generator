# asos-codegen

An OpenAPI code generator shipping the **`swiftASOS`** generator: a Swift client generator following ASOS conventions.

The project is a Maven multi-module build. The usual `asos-codegen-cli.jar` commands (`generate`, `batch`, `config-help`, `list`, `validate`, ...) are available.

## Layout

| Path | Purpose |
| --- | --- |
| `modules/asos-codegen-core` | Core generator API |
| `modules/asos-codegen` | Generation engine, the `swiftASOS` generator and its Mustache templates |
| `modules/asos-codegen-cli` | Command line interface, builds `asos-codegen-cli.jar` |
| `modules/asos-codegen/src/main/java/com/asos/codegen/languages/SwiftASOSClientCodegen.java` | The generator |
| `modules/asos-codegen/src/main/resources/swiftASOS/` | Templates |
| `modules/asos-codegen/src/test/java/com/asos/codegen/swiftASOS/` | Generator unit tests |
| `bin/configs/` | Sample configurations, used by `bin/generate-samples.sh` |
| `samples/client/petstore/swiftASOS/` | Generated samples (source-controlled; regenerate after generator changes) |

## Requirements

- Java 11 (`brew install openjdk@11`)
- Maven is provided through the wrapper (`./mvnw`)
- Swift 5.9+ / Xcode to build the generated samples

## Build

```sh
./mvnw clean package
```

Run only the generator tests:

```sh
./mvnw -pl modules/asos-codegen test -Dtest='com.asos.codegen.swiftASOS.*'
```

## Generate a client

```sh
java -jar modules/asos-codegen-cli/target/asos-codegen-cli.jar generate \
  -g swiftASOS \
  -i path/to/openapi.yaml \
  -o out
```

List all options:

```sh
java -jar modules/asos-codegen-cli/target/asos-codegen-cli.jar config-help -g swiftASOS
```

Or use the helper script at the repository root (builds the jar first unless `--ignore-build` is passed):

```sh
sh ../scripts/codegen-tool.sh -i path/to/openapi.yaml -o out
```

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
