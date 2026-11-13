//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Animal: Equatable, Sendable {
    // MARK: - Properties

    public let className: String

    public let color: String?

    // MARK: - Constructor

    public init(
        className: String,
        color: String? = "red"
    ) {
        self.className = className
        self.color = color
    }

}

// MARK: - Codable

extension Animal: Codable {}

