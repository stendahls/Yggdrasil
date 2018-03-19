//
//  RequestTest.swift
//  Yggdrasil_Tests
//
//  Created by Thomas Sempf on 2018-03-19.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Yggdrasil

class RequestTest: XCTestCase {
        
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNetworkRequestInit() {
        let endpoint = NetworkEndpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = NetworkRequest(endpoint: endpoint, ignoreCache: true, retryCount: 42)
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreCache == true)
        XCTAssert(request.retryCount == 42)
    }
    
    func testNetworkRequestInitStandardParameters() {
        let endpoint = NetworkEndpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = NetworkRequest(endpoint: endpoint)
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreCache == false)
        XCTAssert(request.retryCount == 0)
        XCTAssert(request.body == nil)
        XCTAssert(request.headers.count == 0)
        XCTAssert(request.responseValidations.count == 0)
        XCTAssert(request.preconditions.count == 0)
    }
    
    func testRequestFullURL() {
        let endpoint = NetworkEndpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = NetworkRequest(endpoint: endpoint)
        
        XCTAssert(try request.fullURL.asURL() == URL(string: "https://FooBar.com/FooBar"))
    }
    
    func testNetworkMultipartFormDataRequestInit() {
        let endpoint = NetworkEndpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = NetworkMultipartFormDataRequest(endpoint: endpoint,
                                                      data: "FooBar".data(using: .utf8)!,
                                                      mimeType: "FooBar",
                                                      filename: "FooBar",
                                                      ignoreCache: true,
                                                      retryCount: 42)
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreCache == true)
        XCTAssert(request.retryCount == 42)
        XCTAssert(request.body == nil)
        XCTAssert(request.headers.count == 0)
        XCTAssert(request.responseValidations.count == 0)
        XCTAssert(request.preconditions.count == 0)
        XCTAssert(request.data == "FooBar".data(using: .utf8)!)
        XCTAssert(request.mimeType == "FooBar")
        XCTAssert(request.filename == "FooBar")
    }
    
    func testNetworkMultipartFormDataRequestInitStandardParameters() {
        let endpoint = NetworkEndpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = NetworkMultipartFormDataRequest(endpoint: endpoint,
                                                      data: "FooBar".data(using: .utf8)!,
                                                      mimeType: "FooBar",
                                                      filename: "FooBar")
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreCache == false)
        XCTAssert(request.retryCount == 0)
        XCTAssert(request.body == nil)
        XCTAssert(request.headers.count == 0)
        XCTAssert(request.responseValidations.count == 0)
        XCTAssert(request.preconditions.count == 0)
        XCTAssert(request.data == "FooBar".data(using: .utf8)!)
        XCTAssert(request.mimeType == "FooBar")
        XCTAssert(request.filename == "FooBar")
    }
}
