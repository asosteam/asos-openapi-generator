//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct NumberOnly: Equatable, Sendable {
    // MARK: - Properties

    public let justNumber: Double?

    // MARK: - Constructor

    public init(justNumber: Double?) {
        self.justNumber = justNumber
    }

}

// MARK: - Codable

extension NumberOnly: Codable {
    private enum CodingKeys: String, CodingKey {
        case justNumber = "JustNumber"
    }
}

