//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Model for testing model name starting with number
public struct Model200Response: Equatable, Sendable {
    // MARK: - Properties

    public let name: Int?

    public let _class: String?

    // MARK: - Constructor

    public init(
        name: Int?,
        _class: String?
    ) {
        self.name = name
        self._class = _class
    }

}

// MARK: - Codable

extension Model200Response: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case _class = "class"
    }
}

