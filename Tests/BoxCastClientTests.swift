//
//  BoxCastClientTests.swift
//  BoxCastTests
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import XCTest
@testable import BoxCast

class BoxCastClientTests: XCTestCase {
    
    var client: BoxCastClient?
    
    override func setUp() {
        super.setUp()
        
        // Set up mocking of the responses.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses?.insert(MockedURLProtocol.self, at: 0)
        client = BoxCastClient(configuration: configuration)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApiEndpoint() {
        XCTAssertEqual(client?.apiURL, "https://api.boxcast.com")
    }
    
}
