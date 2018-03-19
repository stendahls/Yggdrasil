//
//  JSONDecodable.swift
//  Nätverk
//
//  Created by Thomas Sempf on 2018-03-02.
//  Copyright © 2018 Stendahls AB. All rights reserved.
//

import Foundation
import Yggdrasil

public typealias JSONDictionary = [String: AnyJSONType]

public protocol JSONType: Decodable {
    var jsonValue: Any { get }
}

extension Int: JSONType {
    public var jsonValue: Any { return self }
}
extension String: JSONType {
    public var jsonValue: Any { return self }
}
extension Double: JSONType {
    public var jsonValue: Any { return self }
}
extension Bool: JSONType {
    public var jsonValue: Any { return self }
}

public struct AnyJSONType: JSONType {
    public let jsonValue: Any

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            jsonValue = intValue
        } else if let stringValue = try? container.decode(String.self) {
            jsonValue = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            jsonValue = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            jsonValue = doubleValue
        } else if let nestedArray = try? container.decode(Array<AnyJSONType>.self) {
            jsonValue = nestedArray
        } else if let nesteDictionary = try? container.decode(Dictionary<String, AnyJSONType>.self) {
            jsonValue = nesteDictionary
        } else {
            jsonValue = NSNull()
        }
    }
}

// MARK: - Make JSONDictionary support Parsable

extension Dictionary: Parsable where Key == String, Value == AnyJSONType {
    public static func parseData(_ data: Data) throws -> Dictionary<Key, Value> {
        return try JSONDecoder().decode(Dictionary<Key, Value>.self, from: data)
    }
}
