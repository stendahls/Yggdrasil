//
//  NetworkEndpointTests.swift
//  Yggdrasil_Tests
//
//  Created by Thomas Sempf on 2018-03-19.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import Yggdrasil

class NetworkEndpointTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNetworkEndpointInit() {
        let endpoint = NetworkEndpoint(baseUrl: "https://FooBar.com",
                                       path: "/FooBar",
                                       method: .post,
                                       parameters: ["Foo" : "Bar"])
        
        XCTAssert(endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(endpoint.path == "/FooBar")
        XCTAssert(endpoint.method == .post)
        XCTAssert(endpoint.parameters as! [String: String] == ["Foo" : "Bar"])
    }
    
    func testNetworkEndpointInitStandardParameters() {
        let endpoint = NetworkEndpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        
        XCTAssert(endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(endpoint.path == "/FooBar")
        XCTAssert(endpoint.method == .get)
        XCTAssert(endpoint.parameters.count == 0)
    }
}
