//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct EnumArrays: Equatable, Sendable {
    // MARK: - Properties
    public enum JustSymbol: String, Codable, CaseIterable, Sendable {
        case greaterThanOrEqualTo = ">="
        case dollar = "$"
    }
    public enum ArrayEnum: String, Codable, CaseIterable, Sendable {
        case fish = "fish"
        case crab = "crab"
    }

    public let justSymbol: JustSymbol?

    public let arrayEnum: [ArrayEnum]?

    // MARK: - Constructor

    public init(
        justSymbol: JustSymbol?,
        arrayEnum: [ArrayEnum]?
    ) {
        self.justSymbol = justSymbol
        self.arrayEnum = arrayEnum
    }

}

// MARK: - Codable

extension EnumArrays: Codable {
    private enum CodingKeys: String, CodingKey {
        case justSymbol = "just_symbol"
        case arrayEnum = "array_enum"
    }
}

