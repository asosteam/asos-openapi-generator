//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct ArrayTest: Equatable, Sendable {
    // MARK: - Properties

    public let arrayOfString: [String]?

    public let arrayArrayOfInteger: [[Int64]]?

    public let arrayArrayOfModel: [[ReadOnlyFirst]]?

    // MARK: - Constructor

    public init(
        arrayOfString: [String]?,
        arrayArrayOfInteger: [[Int64]]?,
        arrayArrayOfModel: [[ReadOnlyFirst]]?
    ) {
        self.arrayOfString = arrayOfString
        self.arrayArrayOfInteger = arrayArrayOfInteger
        self.arrayArrayOfModel = arrayArrayOfModel
    }

}

// MARK: - Codable

extension ArrayTest: Codable {
    private enum CodingKeys: String, CodingKey {
        case arrayOfString = "array_of_string"
        case arrayArrayOfInteger = "array_array_of_integer"
        case arrayArrayOfModel = "array_array_of_model"
    }
}

