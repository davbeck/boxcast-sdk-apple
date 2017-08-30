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
    
    func testApiEndpoint() {
        let client = BoxCastClient(scope: PublicScope())
        XCTAssertEqual(client.scope.apiURL, "https://api.boxcast.com")
    }
    
}
