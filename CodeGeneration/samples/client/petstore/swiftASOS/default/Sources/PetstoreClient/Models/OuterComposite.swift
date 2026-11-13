//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct OuterComposite: Equatable, Sendable {
    // MARK: - Properties

    public let myNumber: Double?

    public let myString: String?

    public let myBoolean: Bool?


    // MARK: - Constructor

    public init(
        myNumber: Double?,
        myString: String?,
        myBoolean: Bool?
    ) {
        self.myNumber = myNumber
        self.myString = myString
        self.myBoolean = myBoolean
    }

}

// MARK: - Codable

extension OuterComposite: Codable {
    private enum CodingKeys: String, CodingKey {
        case myNumber = "my_number"
        case myString = "my_string"
        case myBoolean = "my_boolean"
    }
}

