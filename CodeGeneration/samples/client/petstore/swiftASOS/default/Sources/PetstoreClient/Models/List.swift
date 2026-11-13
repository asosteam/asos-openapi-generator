//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct List: Equatable, Sendable {
    // MARK: - Properties

    public let _123list: String?

}

// MARK: - Codable

extension List: Codable {
    private enum CodingKeys: String, CodingKey {
        case _123list = "123-list"
    }
}

