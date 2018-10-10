//
//  NetworkBase.swift
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

public class BaseTask: NSObject, ProgressReporting {
    public let executionQueue: DispatchQueue = .utility
    public var progress: Progress
    
    let networkRequest: RequestType
    
    internal init(request: RequestType) {
        self.networkRequest = request
        self.progress = Progress(totalUnitCount: 1)
    }
        
    internal lazy var sessionManager: Alamofire.SessionManager = {
        let sessionManager = SessionManager()
        sessionManager.retrier = TaskRetrier(retryCount: networkRequest.retryCount)
        return sessionManager
    }()
    
    internal func preconditionValidation() -> ValidationResult {
        for precondition in networkRequest.preconditions {
            if case .failure(let error) = precondition() {
                return .failure(error)
            }
        }
        
        return .success
    }
    
    internal func responseValidation(request: URLRequest?, response: HTTPURLResponse, data: Data?) -> Alamofire.Request.ValidationResult {
        for validator in self.networkRequest.responseValidations {
            if case .failure(let error) = validator(request, response, data) {
                return .failure(error)
            }
        }
        
        return .success
    }    
}

struct TaskRetrier: RequestRetrier {
    let retryCount: Int
    
    public func should(_ manager: SessionManager, retry request: Alamofire.Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        guard request.retryCount < self.retryCount else {
            completion(false, 0)
            return
        }
        
        completion(true, 0)
    }
}
