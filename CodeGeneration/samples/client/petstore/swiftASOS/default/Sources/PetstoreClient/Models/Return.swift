//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Model for testing reserved words
public struct Return: Equatable, Sendable {
    // MARK: - Properties

    public let _return: Int?

}

// MARK: - Codable

extension Return: Codable {
    private enum CodingKeys: String, CodingKey {
        case _return = "return"
    }
}

