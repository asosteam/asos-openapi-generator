//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Client: Equatable, Sendable {
    // MARK: - Properties

    public let client: String?


    // MARK: - Constructor

    public init(client: String?) {
        self.client = client
    }

}

// MARK: - Codable

extension Client: Codable {}

