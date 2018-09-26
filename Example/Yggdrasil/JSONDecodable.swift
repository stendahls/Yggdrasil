//
//  JSONDecodable.swift
//  Yggdrasil
//
//  Created by Thomas Sempf on 2017-12-08.
//  Copyright © 2017 Stendahls AB. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
