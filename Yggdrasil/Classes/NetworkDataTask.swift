//
//  NetworkDataTask.swift
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

public class NetworkDataTask<T: Decodable>: NetworkBase, ThrowableTaskType {
    public typealias ResultType = T
    
    public func action(completion: @escaping (TaskResult<T>) -> Void) {
        if case .failure(let error) = preconditionValidation() {
            completion(TaskResult.failure(error))
            return
        }
        
        do {
            let dataRequest = try createDataRequest()
            
            executeDataRequest(dataRequest, with: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    private func createDataRequest() throws -> Alamofire.DataRequest {
        var urlRequest = try URLRequest(url: networkRequest.fullURL, method: networkRequest.endpoint.method, headers: networkRequest.headers)
        urlRequest.cachePolicy =  networkRequest.ignoreCache ? .reloadIgnoringCacheData : .useProtocolCachePolicy
        
        let encoding: ParameterEncoding = networkRequest.body ?? URLEncoding.default
        let encodedURLRequest = try encoding.encode(urlRequest, with: networkRequest.endpoint.parameters)
        
        return sessionManager.request(encodedURLRequest)
    }
    
    private func executeDataRequest(_ request: Alamofire.DataRequest, with completion: @escaping (TaskResult<T>) -> Void) {
        request
            .validate()
            .validate(responseValidation)
            .responseData { (response) in
                switch response.result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    do {
                        let result: ResultType = try self.decodeData(data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                }
        }
        
        self.progress.addChild(request.progress, withPendingUnitCount: 1)
    }
}
