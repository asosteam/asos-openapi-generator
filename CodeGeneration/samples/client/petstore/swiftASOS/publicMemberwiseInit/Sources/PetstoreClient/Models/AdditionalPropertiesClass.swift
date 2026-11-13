//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct AdditionalPropertiesClass: Equatable, Sendable {
    // MARK: - Properties

    public let mapString: [String: String]?

    public let mapMapString: [String: [String: String]]?

    // MARK: - Constructor

    public init(
        mapString: [String: String]?,
        mapMapString: [String: [String: String]]?
    ) {
        self.mapString = mapString
        self.mapMapString = mapMapString
    }

}

// MARK: - Codable

extension AdditionalPropertiesClass: Codable {
    private enum CodingKeys: String, CodingKey {
        case mapString = "map_string"
        case mapMapString = "map_map_string"
    }
}

