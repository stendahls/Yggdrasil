//
//  NetworkDownloadTaskTests.swift
//  Yggdrasil_Tests
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

import XCTest
@testable import Yggdrasil

class NetworkDownloadTaskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private struct TestRequest: Yggdrasil.RequestType {
        var endpoint: EndpointType { return Endpoint(baseUrl: "https://httpbin.org", path: "/get") }
        var preconditions: [PreconditionValidation] = []
        var responseValidations: [ResponseValidation] = []
        var retryCount: Int = 0
        var headers: [String : String] = ["Test": "Test"]
        var ignoreCache: Bool = true
        
        init(preconditions: [PreconditionValidation] = [], responseValidations: [ResponseValidation] = [], retryCount: Int = 0) {
            self.preconditions = preconditions
            self.responseValidations = responseValidations
            self.retryCount = retryCount
        }
    }
    
    func testCreationOfDownloadRequest() {
        let request = TestRequest()
        let downloadTask = DownloadTask(request: request)
        let temporaryFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        do {
            let downloadRequest = try downloadTask.createDownloadRequest(toFileURL: temporaryFileURL)
            let fullRequestURL = try request.fullURL.asURL()
            
            XCTAssert(downloadRequest.request?.url == fullRequestURL)
            XCTAssert(downloadRequest.request?.httpMethod == request.endpoint.method.rawValue)
            XCTAssert(downloadRequest.request?.allHTTPHeaderFields == request.headers)
            XCTAssert(downloadRequest.request?.cachePolicy == .reloadIgnoringCacheData)
        } catch {
            XCTFail()
        }
    }
    
    func testProgressReportingIsTriggered() {
        let request = TestRequest()
        let downloadTask = DownloadTask(request: request)
        let finishedExpectation = expectation(description: "Finished")

        DispatchQueue.global().async {
            do {
                let fileURL = try downloadTask.await()
                
                XCTAssert(downloadTask.progress.completedUnitCount == 1)
                XCTAssert(downloadTask.progress.fractionCompleted == 1.0)
                
                try FileManager.default.removeItem(at: fileURL)
                
                finishedExpectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSuccessCase() {
        let request = TestRequest()
        let downloadTask = DownloadTask(request: request)
        let finishedExpectation = expectation(description: "Finished")

        downloadTask.async(completion: { (result) in
            defer { finishedExpectation.fulfill() }
            
            guard case let .success(fileURL) = result else {
                XCTFail("Wrong result")
                return
            }
            
            XCTAssert(FileManager.default.fileExists(atPath: fileURL.relativePath))
            
            try? FileManager.default.removeItem(at: fileURL)
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFailureCase() {
        let downloadTask = DownloadTask(url: "https://httpbin.org/status/500")
        let finishedExpectation = expectation(description: "Finished")

        downloadTask.async(completion: { (result) in
            defer { finishedExpectation.fulfill() }
            
            guard case .failure = result else {
                XCTFail("Wrong result")
                return
            }
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testResponseValidationWithTemporaryURL() {
        let temporaryData = "Foo".data(using: .utf8)!
        let temporaryFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        do {
            try temporaryData.write(to: temporaryFileURL)
        } catch {
            XCTFail()
        }
        
        let validateTemporaryData: ResponseValidation = { (request, response, data) in
            XCTAssert(data == temporaryData)
            return .success
        }
        
        let request = TestRequest(responseValidations: [validateTemporaryData])
        let downloadTask = DownloadTask(request: request)
        let _ = downloadTask.responseValidation(request: nil, response: HTTPURLResponse(), temporaryURL: temporaryFileURL, destinationURL: nil)
    }
    
    func testResponseValidationWithDestinationURL() {
        let destinationData = "Bar".data(using: .utf8)!
        let destinationFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        do {
            try destinationData.write(to: destinationFileURL)
        } catch {
            XCTFail()
        }
        
        let validateDestinationData: ResponseValidation = { (request, response, data) in
            XCTAssert(data == destinationData)
            return .success
        }
        
        let request = TestRequest(responseValidations: [validateDestinationData])
        let downloadTask = DownloadTask(request: request)
        let _ = downloadTask.responseValidation(request: nil, response: HTTPURLResponse(), temporaryURL: nil, destinationURL: destinationFileURL)
    }
    
    func testResponseValidationWithTemporaryAndDestinationURL() {
        let temporaryData = "Foo".data(using: .utf8)!
        let destinationData = "Bar".data(using: .utf8)!
        let temporaryFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let destinationFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        
        do {
            try temporaryData.write(to: temporaryFileURL)
            try destinationData.write(to: destinationFileURL)
        } catch {
            XCTFail()
        }
        
        let validateTemporaryData: ResponseValidation = { (request, response, data) in
            XCTAssert(data != temporaryData)
            return .success
        }
        
        let validateDestinationData: ResponseValidation = { (request, response, data) in
            XCTAssert(data == destinationData)
            return .success
        }
        
        let request = TestRequest(responseValidations: [validateDestinationData, validateTemporaryData])
        let downloadTask = DownloadTask(request: request)
        let _ = downloadTask.responseValidation(request: nil, response: HTTPURLResponse(), temporaryURL: temporaryFileURL, destinationURL: destinationFileURL)
    }
}
