//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct FileSchemaTestClass: Equatable, Sendable {
    // MARK: - Properties

    public let file: File?

    public let files: [File]?

    // MARK: - Constructor

    public init(
        file: File?,
        files: [File]?
    ) {
        self.file = file
        self.files = files
    }

}

// MARK: - Codable

extension FileSchemaTestClass: Codable {}

