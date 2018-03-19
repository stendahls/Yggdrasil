//
//  Parsable.swift
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

import Foundation

public protocol Parsable {
    static func parseData(_ data: Data) throws -> Self
}

// MARK: - Extension for Decodable support

public extension Parsable {
    static func parseData<T: Decodable>(_ data: Data) throws -> T {
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Make Data support Parsable

extension Data: Parsable {
    public static func parseData(_ data: Data) throws -> Data  {
        return data
    }
}

// MARK: - Make Array support Parsable

extension Array: Parsable where Element: Decodable {
    public static func parseData(_ data: Data) throws -> Array<Element> {
        return try JSONDecoder().decode([Element].self, from: data)
    }
}
