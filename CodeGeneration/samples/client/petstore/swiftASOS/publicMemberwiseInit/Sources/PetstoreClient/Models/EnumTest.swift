//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct EnumTest: Equatable, Sendable {
    // MARK: - Properties
    public enum EnumString: String, Codable, CaseIterable, Sendable {
        case upper = "UPPER"
        case lower = "lower"
        case empty = ""
    }
    public enum EnumStringRequired: String, Codable, CaseIterable, Sendable {
        case upper = "UPPER"
        case lower = "lower"
        case empty = ""
    }
    public enum EnumInteger: Int, Codable, CaseIterable, Sendable {
        case _1 = 1
        case number1 = -1
    }
    public enum EnumNumber: Double, Codable, CaseIterable, Sendable {
        case _11 = 1.1
        case number12 = -1.2
    }

    public let enumString: EnumString?

    public let enumStringRequired: EnumStringRequired

    public let enumInteger: EnumInteger?

    public let enumNumber: EnumNumber?

    public let outerEnum: OuterEnum?

    // MARK: - Constructor

    public init(
        enumString: EnumString?,
        enumStringRequired: EnumStringRequired,
        enumInteger: EnumInteger?,
        enumNumber: EnumNumber?,
        outerEnum: OuterEnum?
    ) {
        self.enumString = enumString
        self.enumStringRequired = enumStringRequired
        self.enumInteger = enumInteger
        self.enumNumber = enumNumber
        self.outerEnum = outerEnum
    }

}

// MARK: - Codable

extension EnumTest: Codable {
    private enum CodingKeys: String, CodingKey {
        case enumString = "enum_string"
        case enumStringRequired = "enum_string_required"
        case enumInteger = "enum_integer"
        case enumNumber = "enum_number"
        case outerEnum
    }
}

