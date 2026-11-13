//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Category: Equatable, Sendable {
    // MARK: - Properties

    public let id: Int64?

    public let name: String? = "default-name"

}

// MARK: - Codable

extension Category: Codable {}

