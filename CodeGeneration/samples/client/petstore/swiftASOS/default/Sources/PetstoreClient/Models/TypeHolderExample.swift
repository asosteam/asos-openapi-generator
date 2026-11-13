//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct TypeHolderExample: Equatable, Sendable {
    // MARK: - Properties

    public let stringItem: String

    public let numberItem: Double

    public let integerItem: Int

    public let boolItem: Bool

    public let arrayItem: [Int]

}

// MARK: - Codable

extension TypeHolderExample: Codable {
    private enum CodingKeys: String, CodingKey {
        case stringItem = "string_item"
        case numberItem = "number_item"
        case integerItem = "integer_item"
        case boolItem = "bool_item"
        case arrayItem = "array_item"
    }
}

