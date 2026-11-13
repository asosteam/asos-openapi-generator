//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Model for testing reserved words
public struct Return: Equatable, Sendable {
    // MARK: - Properties

    public let _return: Int?

    // MARK: - Constructor

    public init(_return: Int?) {
        self._return = _return
    }

}

// MARK: - Codable

extension Return: Codable {
    private enum CodingKeys: String, CodingKey {
        case _return = "return"
    }
}

