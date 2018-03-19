//
//  Endpoint.swift
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
import Alamofire

public protocol Endpoint {
    var baseUrl: String { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var parameters: [String: Any] { get }
}

public extension Endpoint {
    var method: Alamofire.HTTPMethod { return .get }
    var parameters: [String: Any] { return [:] }
}

public struct NetworkEndpoint: Endpoint {
    public let baseUrl: String
    public let path: String
    public let method: Alamofire.HTTPMethod
    public let parameters: [String : Any]
    
    public init(baseUrl: String, path: String, method: Alamofire.HTTPMethod = .get, parameters: [String : Any] = [:]) {
        self.baseUrl = baseUrl
        self.path = path
        self.method = method
        self.parameters = parameters
    }
}
