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

public protocol EndpointType {
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any] { get }
}

public extension EndpointType {
    var method: HTTPMethod { return .get }
    var parameters: [String: Any] { return [:] }
}

public struct Endpoint: EndpointType {
    public let baseUrl: String
    public let path: String
    public let method: HTTPMethod
    public let parameters: [String : Any]
    
    public init(baseUrl: String, path: String, method: HTTPMethod = .get, parameters: [String : Any] = [:]) {
        self.baseUrl = baseUrl
        self.path = path
        self.method = method
        self.parameters = parameters
    }
}

// MARK: - HTTP method definitions.

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

internal extension HTTPMethod {
    var asAlamofireHTTPMethod: Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod(rawValue: self.rawValue)!
    }
}

// MARK: - Helper extension to convert String to Endpoint

public extension String {
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw YggdrasilError.invalidURL(url: self)
        }
        
        return url
    }
    
    public func asEndpoint(withMethod method: HTTPMethod = .get) throws -> EndpointType {
        let url = try self.asURL()
        
        return  Endpoint(baseUrl: (url.scheme ?? "") + "://" + (url.host ?? ""), path: url.path, method: method)
    }
}
