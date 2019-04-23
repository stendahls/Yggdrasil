//
//  NetworkMultipartFormDataUploadTask.swift
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

public class MultipartFormDataUploadTask<T: Parsable>: BaseTask, ThrowableTaskType {
    public typealias ResultType = T
    
    public init(request: MultipartFormDataRequestType) {
        super.init(request: request)
    }
    
    public convenience init(url: String, data: Data, mimeType: String, dataName: String, fileName: String?) {
        let endpoint = (try? url.asEndpoint()) ?? Endpoint(baseUrl: "", path: "", method: .post)

        let request = MultipartFormDataRequest(endpoint: endpoint,
                                               data: data,
                                               mimeType: mimeType,
                                               dataName: dataName,
                                               fileName: fileName)
        
        self.init(request: request)
    }
    
    public func action(completion: @escaping (Swift.Result<T, Error>) -> Void) {
        if case .failure(let error) = preconditionValidation() {
            completion(.failure(error))
            return
        }
        
        do {
            let uploadRequest = try createUploadRequest(networkRequest as! MultipartFormDataRequestType).await()
            
            executeUploadRequest(uploadRequest, with: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    internal func createUploadRequest(_ multipartRequest: MultipartFormDataRequestType) -> ThrowableTask<UploadRequest> {
        return ThrowableTask<UploadRequest>(action: { (completion) in
            self.sessionManager.upload(
                multipartFormData: { (multipartFormData) in
                    for (key, value) in self.networkRequest.endpoint.parameters {
                        let data = "\(value)".data(using: String.Encoding.utf8)!
                        multipartFormData.append(data, withName: key as String)
                    }
                    
                    if let filename = multipartRequest.fileName {
                        multipartFormData.append(multipartRequest.data,
                                                 withName: multipartRequest.dataName,
                                                 fileName: filename,
                                                 mimeType: multipartRequest.mimeType)
                    } else {
                        multipartFormData.append(multipartRequest.data,
                                                 withName: multipartRequest.dataName,
                                                 mimeType: multipartRequest.mimeType)
                    }
                },
                to: self.networkRequest.endpoint.baseUrl + self.networkRequest.endpoint.path,
                method: self.networkRequest.endpoint.method.asAlamofireHTTPMethod,
                headers: self.networkRequest.headers,
                encodingCompletion: { (encodingResult) in
                    switch encodingResult {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success(let upload, _, _):
                        completion(.success(upload))
                    }
                }
            )
        })
    }
    
    internal func executeUploadRequest(_ request: Alamofire.UploadRequest, with completion: @escaping (Swift.Result<T, Error>) -> Void) {
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
