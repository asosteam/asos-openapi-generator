//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Dog: Equatable, Sendable {
    // MARK: - Properties

    public let className: String

    public let color: String? = "red"

    public let breed: String?

}

// MARK: - Codable

extension Dog: Codable {}

