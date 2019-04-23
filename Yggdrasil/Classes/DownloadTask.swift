//
//  NetworkDownloadTask.swift
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

public class DownloadTask: BaseTask, ThrowableTaskType {
    public typealias ResultType = URL
    
    private let downloadDestination: URL
    
    public init(request: RequestType, downloadDestination: URL? = nil) {
        if let downloadDestination = downloadDestination {
            self.downloadDestination = downloadDestination
        } else {
            self.downloadDestination = FileManager.default
                .temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
        }
        
        super.init(request: request)
    }
    
    public convenience init(endpoint: EndpointType, downloadDestination: URL? = nil) {
        let request = Request(endpoint: endpoint)
        
        self.init(request: request, downloadDestination: downloadDestination)
    }
    
    public convenience init(url: String, downloadDestination: URL? = nil) {
        let endpoint = (try? url.asEndpoint()) ?? Endpoint(baseUrl: "", path: "")
        
        self.init(endpoint: endpoint, downloadDestination: downloadDestination)
    }
    
    public func action(completion: @escaping (Swift.Result<URL, Error>) -> Void) {
        if case .failure(let error) = preconditionValidation() {
            completion(.failure(error))
            return
        }
        
        do {
            let downloadRequest = try createDownloadRequest(toFileURL: downloadDestination)
            executeDownloadRequest(downloadRequest, with: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    internal func createDownloadRequest(toFileURL fileURL: URL) throws -> Alamofire.DownloadRequest {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        var urlRequest = try URLRequest(url: networkRequest.fullURL(),
                                        method: networkRequest.endpoint.method.asAlamofireHTTPMethod,
                                        headers: networkRequest.headers)
        
        urlRequest.cachePolicy =  networkRequest.ignoreLocalCache ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
        
        let encoding: ParameterEncoding = networkRequest.body ?? URLEncoding.default
        let encodedURLRequest = try encoding.encode(urlRequest, with: networkRequest.endpoint.parameters)
        
        return sessionManager.download(encodedURLRequest, to: destination)
    }
    
    internal func executeDownloadRequest(_ request: Alamofire.DownloadRequest, with completion: @escaping (Swift.Result<URL, Error>) -> Void) {
        request
            .validate()
            .validate(responseValidation)
            .response { (response) in
                guard response.error == nil else {
                    completion(.failure(response.error!))
                    return
                }
                
                if let destinationURL = response.destinationURL {
                    completion(.success(destinationURL))
                    return
                }
                
                if let temporaryURL = response.temporaryURL {
                    completion(.success(temporaryURL))
                    return
                }
                
                completion(.failure(YggdrasilError.unknown))
        }
        
        self.progress.addChild(request.progress, withPendingUnitCount: 1)
    }
    
    internal func responseValidation(request: URLRequest?, response: HTTPURLResponse, temporaryURL: URL?, destinationURL: URL?) -> Alamofire.Request.ValidationResult {
        var data: Data? = nil
        
        if let destinationURL = destinationURL {
            data = try? Data(contentsOf: destinationURL)
        }
        else if let temporaryURL = temporaryURL {
            data = try? Data(contentsOf: temporaryURL)
        }
        
        return responseValidation(request: request, response: response, data: data)
    }
}


