//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Cat: Equatable, Sendable {
    // MARK: - Properties

    public let className: String

    public let color: String? = "red"

    public let declawed: Bool?

}

// MARK: - Codable

extension Cat: Codable {}

