//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Cat: Equatable, Sendable {
    // MARK: - Properties

    public let className: String

    public let color: String?

    public let declawed: Bool?

    // MARK: - Constructor

    public init(
        className: String,
        color: String? = "red",
        declawed: Bool?
    ) {
        self.className = className
        self.color = color
        self.declawed = declawed
    }

}

// MARK: - Codable

extension Cat: Codable {}

