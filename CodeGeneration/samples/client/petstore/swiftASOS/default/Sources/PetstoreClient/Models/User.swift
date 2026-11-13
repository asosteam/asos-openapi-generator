//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct User: Equatable, Sendable {
    // MARK: - Properties

    public let id: Int64?

    public let username: String?

    public let firstName: String?

    public let lastName: String?

    public let email: String?

    public let password: String?

    public let phone: String?

    /// User Status
    public let userStatus: Int?


    // MARK: - Constructor

    public init(
        id: Int64?,
        username: String?,
        firstName: String?,
        lastName: String?,
        email: String?,
        password: String?,
        phone: String?,
        userStatus: Int?
    ) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.phone = phone
        self.userStatus = userStatus
    }

}

// MARK: - Codable

extension User: Codable {}

