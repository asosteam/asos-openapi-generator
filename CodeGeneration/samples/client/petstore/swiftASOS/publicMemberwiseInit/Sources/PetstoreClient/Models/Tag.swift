//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Tag: Equatable, Sendable {
    // MARK: - Properties

    public let id: Int64?

    public let name: String?

    // MARK: - Constructor

    public init(
        id: Int64?,
        name: String?
    ) {
        self.id = id
        self.name = name
    }

}

// MARK: - Codable

extension Tag: Codable {}

