//
//  Request.swift
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
import Taskig
import Alamofire

public enum ValidationResult {
    case success
    case failure(Error)
}

public typealias PreconditionValidation = () -> ValidationResult
public typealias ResponseValidation = (URLRequest?, HTTPURLResponse, Data?) -> ValidationResult

public protocol RequestType {
    var endpoint: EndpointType { get }
    var headers: HTTPHeaders { get }
    var body: String? { get }
    var retryCount: Int { get }
    var responseValidations: [ResponseValidation] { get }
    var preconditions: [PreconditionValidation] { get }
    var ignoreCache: Bool { get }
}

public extension RequestType {
    var body: String? { return nil }
    var headers: [String: String] { return [:] }
    var retryCount: Int { return 0 }
    var responseValidations: [ResponseValidation] { return [] }
    var preconditions: [PreconditionValidation] { return [] }
    var ignoreCache: Bool { return false }
    
    var fullURL: URLConvertible {
        return endpoint.baseUrl + endpoint.path
    }
}

public struct Request: RequestType {
    public let endpoint: EndpointType
    public let ignoreCache: Bool
    public let retryCount: Int
    
    public init(endpoint: EndpointType, ignoreCache: Bool = false, retryCount: Int = 0) {
        self.endpoint = endpoint
        self.ignoreCache = ignoreCache
        self.retryCount = retryCount
    }
}
