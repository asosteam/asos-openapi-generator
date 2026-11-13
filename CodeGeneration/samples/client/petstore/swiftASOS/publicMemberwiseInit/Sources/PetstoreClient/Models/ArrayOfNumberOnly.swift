//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct ArrayOfNumberOnly: Equatable, Sendable {
    // MARK: - Properties

    public let arrayNumber: [Double]?

    // MARK: - Constructor

    public init(arrayNumber: [Double]?) {
        self.arrayNumber = arrayNumber
    }

}

// MARK: - Codable

extension ArrayOfNumberOnly: Codable {
    private enum CodingKeys: String, CodingKey {
        case arrayNumber = "ArrayNumber"
    }
}

