//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Pet: Equatable, Sendable {
    // MARK: - Properties
    public enum Status: String, Codable, CaseIterable, Sendable {
        case available = "available"
        case pending = "pending"
        case sold = "sold"
    }

    public let id: Int64?

    public let category: Category?

    public let name: String

    public let photoURLs: [String]

    public let tags: [Tag]?

    /// pet status in the store
    public let status: NullEncodable<Status>

    // MARK: - Constructor

    public init(
        id: Int64?,
        category: Category?,
        name: String,
        photoURLs: [String],
        tags: [Tag]?,
        status: NullEncodable<Status>
    ) {
        self.id = id
        self.category = category
        self.name = name
        self.photoURLs = photoURLs
        self.tags = tags
        self.status = status
    }

}

// MARK: - Codable

extension Pet: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case category
        case name
        case photoURLs = "photoUrls"
        case tags
        case status
    }
}

