//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct FormatTest: Equatable, Sendable {
    // MARK: - Properties
    static let integerRule = NumericRule<Int>(minimum: 10, exclusiveMinimum: false, maximum: 100, exclusiveMaximum: false, multipleOf: nil)
    static let int32Rule = NumericRule<Int>(minimum: 20, exclusiveMinimum: false, maximum: 200, exclusiveMaximum: false, multipleOf: nil)
    static let numberRule = NumericRule<Double>(minimum: 32.1, exclusiveMinimum: false, maximum: 543.2, exclusiveMaximum: false, multipleOf: nil)
    static let floatRule = NumericRule<Float>(minimum: 54.3, exclusiveMinimum: false, maximum: 987.6, exclusiveMaximum: false, multipleOf: nil)
    static let doubleRule = NumericRule<Double>(minimum: 67.8, exclusiveMinimum: false, maximum: 123.4, exclusiveMaximum: false, multipleOf: nil)
    static let stringRule = StringRule(minLength: nil, maxLength: nil, pattern: "/[a-z]/i")
    static let passwordRule = StringRule(minLength: 10, maxLength: 64, pattern: nil)

    public let integer: Int?

    public let int32: Int?

    public let int64: Int64?

    public let number: Double

    public let float: Float?

    public let double: Double?

    public let string: String?

    public let byte: Data

    public let binary: URL?

    public let date: Date

    public let dateTime: Date?

    public let uuid: UUID?

    public let password: String

    // MARK: - Constructor

    public init(
        integer: Int?,
        int32: Int?,
        int64: Int64?,
        number: Double,
        float: Float?,
        double: Double?,
        string: String?,
        byte: Data,
        binary: URL?,
        date: Date,
        dateTime: Date?,
        uuid: UUID?,
        password: String
    ) {
        self.integer = integer
        self.int32 = int32
        self.int64 = int64
        self.number = number
        self.float = float
        self.double = double
        self.string = string
        self.byte = byte
        self.binary = binary
        self.date = date
        self.dateTime = dateTime
        self.uuid = uuid
        self.password = password
    }

}

// MARK: - Codable

extension FormatTest: Codable {}

