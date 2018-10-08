//
//  RequestTest.swift
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
        let endpoint = Endpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = Request(endpoint: endpoint, ignoreLocalCache: true, retryCount: 42)
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreLocalCache == true)
        XCTAssert(request.retryCount == 42)
    }
    
    func testNetworkRequestInitStandardParameters() {
        let endpoint = Endpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = Request(endpoint: endpoint)
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreLocalCache == false)
        XCTAssert(request.retryCount == 0)
        XCTAssert(request.body == nil)
        XCTAssert(request.headers.count == 0)
        XCTAssert(request.responseValidations.count == 0)
        XCTAssert(request.preconditions.count == 0)
    }
    
    func testRequestFullURL() {
        let endpoint = Endpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = Request(endpoint: endpoint)
        
        XCTAssert(try request.fullURL.asURL() == URL(string: "https://FooBar.com/FooBar"))
    }
    
    func testNetworkMultipartFormDataRequestInit() {
        let endpoint = Endpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = MultipartFormDataRequest(endpoint: endpoint,
                                                      data: "FooBar".data(using: .utf8)!,
                                                      mimeType: "FooBar",
                                                      dataName: "FooBar",
                                                      ignoreLocalCache: true,
                                                      retryCount: 42)
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreLocalCache == true)
        XCTAssert(request.retryCount == 42)
        XCTAssert(request.body == nil)
        XCTAssert(request.headers.count == 0)
        XCTAssert(request.responseValidations.count == 0)
        XCTAssert(request.preconditions.count == 0)
        XCTAssert(request.data == "FooBar".data(using: .utf8)!)
        XCTAssert(request.mimeType == "FooBar")
        XCTAssert(request.dataName == "FooBar")
    }
    
    func testNetworkMultipartFormDataRequestInitStandardParameters() {
        let endpoint = Endpoint(baseUrl: "https://FooBar.com", path: "/FooBar")
        let request = MultipartFormDataRequest(endpoint: endpoint,
                                                      data: "FooBar".data(using: .utf8)!,
                                                      mimeType: "FooBar",
                                                      dataName: "FooBar")
        
        XCTAssert(request.endpoint.baseUrl == "https://FooBar.com")
        XCTAssert(request.endpoint.path == "/FooBar")
        XCTAssert(request.ignoreLocalCache == false)
        XCTAssert(request.retryCount == 0)
        XCTAssert(request.body == nil)
        XCTAssert(request.headers.count == 0)
        XCTAssert(request.responseValidations.count == 0)
        XCTAssert(request.preconditions.count == 0)
        XCTAssert(request.data == "FooBar".data(using: .utf8)!)
        XCTAssert(request.mimeType == "FooBar")
        XCTAssert(request.dataName == "FooBar")
    }
}
