//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

/// Model for testing model with \"_class\" property
public struct ClassModel: Equatable, Sendable {
    // MARK: - Properties

    public let _class: String?

}

// MARK: - Codable

extension ClassModel: Codable {}

