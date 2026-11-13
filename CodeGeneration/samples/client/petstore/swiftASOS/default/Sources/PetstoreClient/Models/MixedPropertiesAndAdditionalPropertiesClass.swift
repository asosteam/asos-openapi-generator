//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct MixedPropertiesAndAdditionalPropertiesClass: Equatable, Sendable {
    // MARK: - Properties

    public let uuid: UUID?

    public let dateTime: Date?

    public let map: [String: Animal]?

}

// MARK: - Codable

extension MixedPropertiesAndAdditionalPropertiesClass: Codable {}

