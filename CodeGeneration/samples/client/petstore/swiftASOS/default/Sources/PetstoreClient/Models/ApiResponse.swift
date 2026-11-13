//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct ApiResponse: Equatable, Sendable {
    // MARK: - Properties

    public let code: Int?

    public let type: String?

    public let message: String?

}

// MARK: - Codable

extension ApiResponse: Codable {}

