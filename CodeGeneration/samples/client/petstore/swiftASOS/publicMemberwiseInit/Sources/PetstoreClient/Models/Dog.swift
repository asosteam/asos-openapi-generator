//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Dog: Equatable, Sendable {
    // MARK: - Properties

    public let className: String

    public let color: String?

    public let breed: String?

    // MARK: - Constructor

    public init(
        className: String,
        color: String? = "red",
        breed: String?
    ) {
        self.className = className
        self.color = color
        self.breed = breed
    }

}

// MARK: - Codable

extension Dog: Codable {}

