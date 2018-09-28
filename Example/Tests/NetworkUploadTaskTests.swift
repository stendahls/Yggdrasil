//
//  NetworkUploadTaskTests.swift
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

class NetworkUploadTaskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private struct TestPostRequest: Yggdrasil.RequestType {
        var endpoint: EndpointType { return Endpoint(baseUrl: "https://httpbin.org", path: "/post", method: .post) }
        var preconditions: [PreconditionValidation] = []
        var responseValidations: [ResponseValidation] = []
        var retryCount: Int = 0
        var headers: [String : String] = ["Test": "Test"]
        
        init(preconditions: [PreconditionValidation] = [], responseValidations: [ResponseValidation] = [], retryCount: Int = 0) {
            self.preconditions = preconditions
            self.responseValidations = responseValidations
            self.retryCount = retryCount
        }
    }
    
    func testCreationOfUploadRequest() {
        let request = TestPostRequest()
        let uploadTask = UploadTask<Data>(request: request, dataToUpload: .data("FooBar".data(using: .utf8)!))
        
        do {
            let uploadRequest = try uploadTask.createUploadRequest()
            let fullRequestURL = try request.fullURL.asURL()
            
            XCTAssert(uploadRequest.request?.url == fullRequestURL)
            XCTAssert(uploadRequest.request?.httpMethod == request.endpoint.method.rawValue)
            XCTAssert(uploadRequest.request?.allHTTPHeaderFields == request.headers)
        } catch {
            XCTFail()
        }
    }
    
    func testProgressReportingIsTriggered() {
        let request = TestPostRequest()
        let uploadTask = UploadTask<Data>(request: request, dataToUpload: .data("FooBar".data(using: .utf8)!))
        let finishedExpectation = expectation(description: "Finished")
        
        DispatchQueue.global().async {
            do {
                try uploadTask.await()
                
                XCTAssert(uploadTask.progress.completedUnitCount == 1)
                XCTAssert(uploadTask.progress.fractionCompleted == 1.0)
                
                finishedExpectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSuccessCase() {
        let request = TestPostRequest()
        let uploadTask = UploadTask<Data>(request: request, dataToUpload: .data("FooBar".data(using: .utf8)!))
        let finishedExpectation = expectation(description: "Finished")
        
        uploadTask.async { (result) in
            defer { finishedExpectation.fulfill() }
            
            guard case .success = result else {
                XCTFail("Wrong result")
                return
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFailureCase() {
        let uploadTask = try! UploadTask<Data>(url: "https://httpbin.org/status/500", dataToUpload: .data("FooBar".data(using: .utf8)!))
        let finishedExpectation = expectation(description: "Finished")
        
        uploadTask.async(completion: { (result) in
            defer { finishedExpectation.fulfill() }
            
            guard case .failure = result else {
                XCTFail("Wrong result")
                return
            }
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
