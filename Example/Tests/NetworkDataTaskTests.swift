//
//  NetworkDataTaskTests.swift
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

class NetworkDataTaskTests: XCTestCase {
    
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
        var ignoreLocalCache: Bool = true
        
        init(preconditions: [PreconditionValidation] = [], responseValidations: [ResponseValidation] = [], retryCount: Int = 0) {
            self.preconditions = preconditions
            self.responseValidations = responseValidations
            self.retryCount = retryCount
        }
    }
    
    func testCreationOfDataRequest() {
        let request = TestRequest()
        let dataTask = DataTask<JSONDictionary>(request: request)
        
        do {
            let dataRequest = try dataTask.createDataRequest()
            let fullRequestURL = try request.fullURL()
            
            XCTAssert(dataRequest.request?.url == fullRequestURL)
            XCTAssert(dataRequest.request?.httpMethod == request.endpoint.method.rawValue)
            XCTAssert(dataRequest.request?.allHTTPHeaderFields == request.headers)
            XCTAssert(dataRequest.request?.cachePolicy == .reloadIgnoringCacheData)
        } catch {
            XCTFail()
        }
    }
    
    func testProgressReportingIsTriggered() {
        let request = TestRequest()
        let dataTask = DataTask<JSONDictionary>(request: request)
        let finishedExpectation = expectation(description: "Finished")
        
        DispatchQueue.global().async {
            do {
                try dataTask.await()
                XCTAssert(dataTask.progress.completedUnitCount == 1)
                XCTAssert(dataTask.progress.fractionCompleted == 1.0)
                finishedExpectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSuccessCase() {
        let request = TestRequest()
        let dataTask = DataTask<JSONDictionary>(request: request)
        let finishedExpectation = expectation(description: "Finished")
        
        dataTask.async(completion: { (result) in
            defer { finishedExpectation.fulfill() }

            guard case .success = result else {
                XCTFail("Wrong result")
                return
            }
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testFailureCase() {
        let dataTask = DataTask<Data>(url: "https://httpbin.org/status/500")
        let finishedExpectation = expectation(description: "Finished")
        
        dataTask.async(completion: { (result) in
            defer { finishedExpectation.fulfill() }
            
            guard case .failure = result else {
                XCTFail("Wrong result")
                return
            }            
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
