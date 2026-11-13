//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct ArrayOfNumberOnly: Equatable, Sendable {
    // MARK: - Properties

    public let arrayNumber: [Double]?

}

// MARK: - Codable

extension ArrayOfNumberOnly: Codable {
    private enum CodingKeys: String, CodingKey {
        case arrayNumber = "ArrayNumber"
    }
}

