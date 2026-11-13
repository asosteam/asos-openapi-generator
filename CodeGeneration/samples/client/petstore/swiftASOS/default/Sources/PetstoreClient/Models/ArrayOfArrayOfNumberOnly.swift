//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct ArrayOfArrayOfNumberOnly: Equatable, Sendable {
    // MARK: - Properties

    public let arrayArrayNumber: [[Double]]?

}

// MARK: - Codable

extension ArrayOfArrayOfNumberOnly: Codable {
    private enum CodingKeys: String, CodingKey {
        case arrayArrayNumber = "ArrayArrayNumber"
    }
}

