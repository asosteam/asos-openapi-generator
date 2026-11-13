//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Model for testing model name same as property name
public struct Name: Equatable, Sendable {
    // MARK: - Properties

    public let name: Int

    public let snakeCase: NullEncodable<Int> = .encodeValue(11033)

    public let property: String?

    public let _123number: Int?

}

// MARK: - Codable

extension Name: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case snakeCase = "snake_case"
        case property
        case _123number = "123Number"
    }
}

