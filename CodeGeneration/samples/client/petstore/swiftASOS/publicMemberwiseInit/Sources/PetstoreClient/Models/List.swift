//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct List: Equatable, Sendable {
    // MARK: - Properties

    public let _123list: String?

    // MARK: - Constructor

    public init(_123list: String?) {
        self._123list = _123list
    }

}

// MARK: - Codable

extension List: Codable {
    private enum CodingKeys: String, CodingKey {
        case _123list = "123-list"
    }
}

