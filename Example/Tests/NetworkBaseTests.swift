//
//  NetworkBaseTests.swift
//  Yggdrasil_Tests
//
//  Created by Thomas Sempf on 2018-03-19.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import Yggdrasil

extension String: Error {}

class NetworkBaseTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    private struct TestRequest: Request {
        typealias Response = JSONDictionary
        
        var endpoint: Endpoint { return NetworkEndpoint(baseUrl: "https://httpbin.org", path: "/get") }
        var preconditions: [PreconditionValidation] = []
        var responseValidations: [ResponseValidation] = []
        
        init(preconditions: [PreconditionValidation] = [], responseValidations: [ResponseValidation] = []) {
            self.preconditions = preconditions
            self.responseValidations = responseValidations
        }
    }
    
    private func testHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "https://httpbin.org/image/jpeg")!,
                               mimeType: "img/jpg",
                               expectedContentLength: 100,
                               textEncodingName: nil)
    }
    
    func testNetworkBaseInit() {
        let validURL = NetworkBase(url: "https://httpbin.org/get")
        
        XCTAssert(validURL.networkRequest.endpoint.baseUrl == "https://httpbin.org")
        XCTAssert(validURL.networkRequest.endpoint.path == "/get")
        
        let invalidURL = NetworkBase(url: " a _ _ ")
        XCTAssert(invalidURL.networkRequest.endpoint.baseUrl == "")
        XCTAssert(invalidURL.networkRequest.endpoint.path == "")
    }
    
    func testPreconditionValidationsCallsAllPreconditions() {
        func successValidation(_ expectation: XCTestExpectation) -> PreconditionValidation {
            return {
                expectation.fulfill()
                return .success
            }
        }
        
        let expectationOne = XCTestExpectation()
        let expectationTwo = XCTestExpectation()
        
        let preconditions = [successValidation(expectationOne), successValidation(expectationTwo)]
        let request = TestRequest(preconditions: preconditions)
        
        if case .failure = NetworkBase(request: request).preconditionValidation() {
            XCTFail()
        }
        
        wait(for: [expectationOne, expectationTwo], timeout: 2)
    }
    
    func testExecutionOfPreconditionValidationsWithSuccessResult() {
        let successPrecondition: PreconditionValidation = { return .success }
        let preconditions = [ successPrecondition, successPrecondition]
        let request = TestRequest(preconditions: preconditions)
        
        if case .failure = NetworkBase(request: request).preconditionValidation() {
            XCTFail()
        }
    }
 
    func testExecutionOfPreconditionValidationsWithFailureResult() {
        let successPrecondition: PreconditionValidation = { return .success }
        let failurePrecondition: PreconditionValidation = { return .failure("Something went wrong") }
        let preconditions = [successPrecondition, failurePrecondition]
        let request = TestRequest(preconditions: preconditions)
        
        if case let .failure(error) = NetworkBase(request: request).preconditionValidation() {
            XCTAssert(error as! String == "Something went wrong")
        } else {
            XCTFail()
        }
    }
    
    func testResponseValidationsCallsAllValidators() {
        func successValidation(_ expectation: XCTestExpectation) -> ResponseValidation {
            return { (_,_,_) in
                expectation.fulfill()
                return .success
            }
        }

        let expectationOne = XCTestExpectation()
        let expectationTwo = XCTestExpectation()

        let responseValidations = [successValidation(expectationOne), successValidation(expectationTwo)]
        let request = TestRequest(responseValidations: responseValidations)
        
        let networkBase = NetworkBase(request: request)
        
        if case .failure = networkBase.responseValidation(request: nil, response: testHTTPURLResponse(), data: nil) {
            XCTFail()
        }
        
        wait(for: [expectationOne, expectationTwo], timeout: 2)
    }
    
    func testResponseValidationParameters() {
        let testRequest = URLRequest(url: URL(string: "https://httpbin.org/image/jpeg")!)
        let testResponse = testHTTPURLResponse()
        let testData = "FooBar".data(using: .utf8)!
        
        let responseValidator: ResponseValidation = { (request, response, data) in
            XCTAssert(request == testRequest)
            XCTAssert(response == testResponse)
            XCTAssert(data == testData)
            
            return .success
        }
        
        let request = TestRequest(responseValidations: [responseValidator])
        let networkBase = NetworkBase(request: request)
        
        if case .failure = networkBase.responseValidation(request: testRequest, response: testResponse, data: testData) {
            XCTFail()
        }
    }
    
    func testExecutionOfResponseValidationsWithSuccessResult() {
        let successValidation: ResponseValidation = { (_,_,_) in return .success }
        let request = TestRequest(responseValidations: [successValidation, successValidation])
        let networkBase = NetworkBase(request: request)
        
        if case .failure = networkBase.responseValidation(request: nil, response: testHTTPURLResponse(), data: nil) {
            XCTFail()
        }
    }
    
    func testExecutionOfResponseValidationsWithFailureResult() {
        let successPrecondition: ResponseValidation = { (_,_,_) in return .success }
        let failurePrecondition: ResponseValidation = { (_,_,_) in return .failure("Something went wrong") }
        let request = TestRequest(responseValidations: [successPrecondition, failurePrecondition])
        let networkBase = NetworkBase(request: request)
        
        if case let .failure(error) = networkBase.responseValidation(request: nil,
                                                                     response: testHTTPURLResponse(),
                                                                     data: nil)
        {
            XCTAssert(error as! String == "Something went wrong")
        } else {
            XCTFail()
        }
    }
    
    func testRequestRetrier() {
//        var request = TestRequest()
//        let networkBase = NetworkBase(request: request)
//
//        let requestRetryCompletion: RequestRetryCompletion = {
//
//        }
//
//        networkBase.should(networkBase.sessionManager, retry: request, with: "Something went wrong") { (<#Bool#>, <#TimeInterval#>) in
//            <#code#>
//        }
    }
}
