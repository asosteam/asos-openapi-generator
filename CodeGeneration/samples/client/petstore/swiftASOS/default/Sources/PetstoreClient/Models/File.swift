//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Must be named `File` for test.
public struct File: Equatable, Sendable {
    // MARK: - Properties

    /// Test capitalization
    public let sourceURI: String?

}

// MARK: - Codable

extension File: Codable {}

