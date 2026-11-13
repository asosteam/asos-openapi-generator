//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct ReadOnlyFirst: Equatable, Sendable {
    // MARK: - Properties

    public let bar: String?

    public let baz: String?

}

// MARK: - Codable

extension ReadOnlyFirst: Codable {}

