# ASOS Code Generation

Tooling for generating ASOS client code from OpenAPI specifications.

| Folder | Contents |
| --- | --- |
| [CodeGeneration/](CodeGeneration/) | `asos-codegen`: the OpenAPI code generator and its Swift (`swiftASOS`) generator |
| [scripts/](scripts/) | `codegen-tool.sh`: builds the generator and produces Swift models from a spec. `create-swift-package.sh`: wraps the generated models of a contract (local file or URL), or of a single chosen endpoint, in a Swift Package |

See [CodeGeneration/README.md](CodeGeneration/README.md) for build and usage instructions.
