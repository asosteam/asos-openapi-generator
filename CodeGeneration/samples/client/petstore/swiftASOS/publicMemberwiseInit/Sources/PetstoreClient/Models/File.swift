//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Must be named `File` for test.
public struct File: Equatable, Sendable {
    // MARK: - Properties

    /// Test capitalization
    public let sourceURI: String?

    // MARK: - Constructor

    public init(sourceURI: String?) {
        self.sourceURI = sourceURI
    }

}

// MARK: - Codable

extension File: Codable {}

