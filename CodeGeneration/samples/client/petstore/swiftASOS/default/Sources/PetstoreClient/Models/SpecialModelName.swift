//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct SpecialModelName: Equatable, Sendable {
    // MARK: - Properties

    public let specialPropertyName: Int64?

}

// MARK: - Codable

extension SpecialModelName: Codable {
    private enum CodingKeys: String, CodingKey {
        case specialPropertyName = "$special[property.name]"
    }
}

