//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct HasOnlyReadOnly: Equatable, Sendable {
    // MARK: - Properties

    public let bar: String?

    public let foo: String?

}

// MARK: - Codable

extension HasOnlyReadOnly: Codable {}

