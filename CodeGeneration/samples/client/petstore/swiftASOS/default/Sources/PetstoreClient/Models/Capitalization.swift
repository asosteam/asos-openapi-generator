//
// Copyright © 2026 ASOS. All rights reserved.
//

import Foundation

public struct Capitalization: Equatable, Sendable {
    // MARK: - Properties

    public let smallCamel: String?

    public let capitalCamel: String?

    public let smallSnake: String?

    public let capitalSnake: String?

    public let sCAETHFlowPoints: String?

    /// Name of the pet 
    public let ATT_NAME: String?

}

// MARK: - Codable

extension Capitalization: Codable {
    private enum CodingKeys: String, CodingKey {
        case smallCamel
        case capitalCamel = "CapitalCamel"
        case smallSnake = "small_Snake"
        case capitalSnake = "Capital_Snake"
        case sCAETHFlowPoints = "SCA_ETH_Flow_Points"
        case ATT_NAME
    }
}

