//
//  NetworkUploadTask.swift
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

public enum UploadData {
    case file(URL)
    case data(Data)
}

public class UploadTask<T: Parsable>: BaseTask, ThrowableTaskType {
    public typealias ResultType = T
    
    private let dataToUpload: UploadData
    
    public init(request: Request, dataToUpload: UploadData) {
        self.dataToUpload = dataToUpload
        
        super.init(request: request)
    }
    
    public init(url: URLConvertible, dataToUpload: UploadData) {
        self.dataToUpload = dataToUpload
        
        var endpoint: NetworkEndpoint
        
        if let url = try? url.asURL() {
            endpoint = NetworkEndpoint(baseUrl: (url.scheme ?? "") + "://" + (url.host ?? ""),
                                       path: url.path,
                                       method: .post)
        } else {
            endpoint = NetworkEndpoint(baseUrl: "", path: "", method: .post)
        }
        
        let request = NetworkRequest(endpoint: endpoint)
        
        super.init(request: request)
    }
    
    public func action(completion: @escaping (TaskResult<T>) -> Void) {
        if case .failure(let error) = preconditionValidation() {
            completion(TaskResult.failure(error))
            return
        }
        
        do {
            let uploadRequest = try createUploadRequest()
            
            executeUploadRequest(uploadRequest, with: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    internal func createUploadRequest() throws -> Alamofire.UploadRequest {
        switch dataToUpload {
        case .data(let data):
            return sessionManager.upload(data,
                                         to: self.networkRequest.endpoint.baseUrl + self.networkRequest.endpoint.path,
                                         method: self.networkRequest.endpoint.method,
                                         headers: self.networkRequest.headers)
        case .file(let fileURL):
            return sessionManager.upload(fileURL,
                                         to: self.networkRequest.endpoint.baseUrl + self.networkRequest.endpoint.path,
                                         method: self.networkRequest.endpoint.method,
                                         headers: self.networkRequest.headers)
        }
    }
    
    internal func executeUploadRequest(_ request: Alamofire.UploadRequest, with completion: @escaping (TaskResult<T>) -> Void) {
        request
            .validate()
            .validate(responseValidation)
            .responseData { (response) in
                switch response.result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    do {
                        let result: ResultType = try ResultType.parseData(data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(error))
                    }
                }
        }
        
        self.progress.addChild(request.progress, withPendingUnitCount: 1)
    }
}

