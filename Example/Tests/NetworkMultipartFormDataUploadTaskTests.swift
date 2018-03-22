//
//  NetworkMultipartFormDataUploadTaskTests.swift
//  Yggdrasil_Tests
//
//  Created by Thomas Sempf on 2018-03-22.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Yggdrasil

class NetworkMultipartFormDataUploadTaskTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private struct TestMultipartRequest: MultipartRequest {
        var data: Data  { return "FooBar".data(using: .utf8)! }
        var mimeType: String = "txt"
        var filename: String = "Foobar.txt"
        
        var endpoint: Endpoint { return NetworkEndpoint(baseUrl: "https://httpbin.org", path: "/post", method: .post) }
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
    
    func testProgressReportingIsTriggered() {
        let request = TestMultipartRequest()
        let uploadTask = MultipartFormDataUploadTask<Data>(request: request)
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
        let request = TestMultipartRequest()
        let uploadTask = MultipartFormDataUploadTask<Data>(request: request)
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
        let request = NetworkMultipartFormDataRequest(endpoint: NetworkEndpoint(baseUrl: "", path: ""), data: "FooBar".data(using: .utf8)!, mimeType: "txt", filename: "Foobar.txt")
        let uploadTask = MultipartFormDataUploadTask<Data>(request: request)
        let finishedExpectation = expectation(description: "Finished")
        
        uploadTask.async(completion: { (result) in
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
