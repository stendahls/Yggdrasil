//
//  NetworkDataTaskTests.swift
//  Yggdrasil_Tests
//
//  Created by Thomas Sempf on 2018-03-20.
//  Copyright © 2018 CocoaPods. All rights reserved.
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
    
    private struct TestRequest: Yggdrasil.Request {
        var endpoint: Endpoint { return NetworkEndpoint(baseUrl: "https://httpbin.org", path: "/get") }
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
    
    func testCreationOfDataRequest() {
        let request = TestRequest()
        let dataTask = NetworkDataTask<JSONDictionary>(request: request)
        
        do {
            let dataRequest = try dataTask.createDataRequest()
            let fullRequestURL = try request.fullURL.asURL()
            
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
        let dataTask = NetworkDataTask<JSONDictionary>(request: request)
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
        let dataTask = NetworkDataTask<JSONDictionary>(request: request)
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
        let dataTask = NetworkDataTask<Data>(url: "")
        let finishedExpectation = expectation(description: "Finished")
        
        dataTask.async(completion: { (result) in
            defer { finishedExpectation.fulfill() }
            
            guard case let .failure(error) = result else {
                XCTFail("Wrong result")
                return
            }
            
            XCTAssert(error.localizedDescription == "URL is not valid: ")
        })
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}
