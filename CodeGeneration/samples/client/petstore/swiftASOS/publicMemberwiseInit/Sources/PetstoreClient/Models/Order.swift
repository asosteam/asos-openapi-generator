//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Order: Equatable, Sendable {
    // MARK: - Properties
    public enum Status: String, Codable, CaseIterable, Sendable {
        case placed = "placed"
        case approved = "approved"
        case delivered = "delivered"
    }

    public let id: Int64?

    public let petID: Int64?

    public let quantity: Int?

    public let shipDate: Date?

    /// Order Status
    public let status: Status?

    public let complete: Bool?

    // MARK: - Constructor

    public init(
        id: Int64?,
        petID: Int64?,
        quantity: Int?,
        shipDate: Date?,
        status: Status?,
        complete: Bool? = false
    ) {
        self.id = id
        self.petID = petID
        self.quantity = quantity
        self.shipDate = shipDate
        self.status = status
        self.complete = complete
    }

}

// MARK: - Codable

extension Order: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case petID = "petId"
        case quantity
        case shipDate
        case status
        case complete
    }
}

