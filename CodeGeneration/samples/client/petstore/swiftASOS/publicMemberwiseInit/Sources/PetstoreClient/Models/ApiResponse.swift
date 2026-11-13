//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct ApiResponse: Equatable, Sendable {
    // MARK: - Properties

    public let code: Int?

    public let type: String?

    public let message: String?

    // MARK: - Constructor

    public init(
        code: Int?,
        type: String?,
        message: String?
    ) {
        self.code = code
        self.type = type
        self.message = message
    }

}

// MARK: - Codable

extension ApiResponse: Codable {}

