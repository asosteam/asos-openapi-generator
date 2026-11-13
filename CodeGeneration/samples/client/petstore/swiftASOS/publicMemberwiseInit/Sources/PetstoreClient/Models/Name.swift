//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Model for testing model name same as property name
public struct Name: Equatable, Sendable {
    // MARK: - Properties

    public let name: Int

    public let snakeCase: NullEncodable<Int>

    public let property: String?

    public let _123number: Int?

    // MARK: - Constructor

    public init(
        name: Int,
        snakeCase: NullEncodable<Int> = .encodeValue(11033),
        property: String?,
        _123number: Int?
    ) {
        self.name = name
        self.snakeCase = snakeCase
        self.property = property
        self._123number = _123number
    }

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

