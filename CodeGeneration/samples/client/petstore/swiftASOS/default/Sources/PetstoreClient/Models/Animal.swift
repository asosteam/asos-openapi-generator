//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Animal: Equatable, Sendable {
    // MARK: - Properties

    public let className: String

    public let color: String? = "red"

}

// MARK: - Codable

extension Animal: Codable {}

