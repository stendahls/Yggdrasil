//
//  MultipartRequest.swift
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
import Taskig

public protocol MultipartRequestType: RequestType {
    var data: Data { get }
    var mimeType: String { get }
    var filename: String { get }    
}

public extension MultipartRequestType {
    var body: String? { return nil }
    var retryCount: Int { return 0 }
    var responseValidations: [Alamofire.DataRequest.Validation] { return [] }
    var preconditions: [PreconditionValidation] { return [] }
}

public struct NetworkMultipartFormDataRequest: MultipartRequestType {
    public let endpoint: EndpointType
    public let ignoreCache: Bool
    public let retryCount: Int
    public let data: Data
    public let mimeType: String
    public let filename: String
    
    public init(endpoint: EndpointType, data: Data, mimeType: String, filename: String, ignoreCache: Bool = false, retryCount: Int = 0) {
        self.endpoint = endpoint
        self.ignoreCache = ignoreCache
        self.retryCount = retryCount
        self.data = data
        self.mimeType = mimeType
        self.filename = filename
    }
}
