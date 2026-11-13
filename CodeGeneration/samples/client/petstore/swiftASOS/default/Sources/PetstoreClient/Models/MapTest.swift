//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct MapTest: Equatable, Sendable {
    // MARK: - Properties
    public enum MapOfEnumString: String, Codable, CaseIterable, Sendable {
        case upper = "UPPER"
        case lower = "lower"
    }

    public let mapMapOfString: [String: [String: String]]?

    public let mapOfEnumString: [String: String]?

    public let directMap: [String: Bool]?

    public let indirectMap: StringBooleanMap?

}

// MARK: - Codable

extension MapTest: Codable {
    private enum CodingKeys: String, CodingKey {
        case mapMapOfString = "map_map_of_string"
        case mapOfEnumString = "map_of_enum_string"
        case directMap = "direct_map"
        case indirectMap = "indirect_map"
    }
}

