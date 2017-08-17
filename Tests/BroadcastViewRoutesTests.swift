//
//  BroadcastViewRoutesTests.swift
//  BoxCast
//
//  Created by Camden Fullmer on 8/17/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import XCTest
@testable import BoxCast

class BroadcastViewRoutesTests: XCTestCase {
    
    var client: BoxCastClient?
    
    override func setUp() {
        super.setUp()
        
        // Set up mocking of the responses.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses?.insert(MockedURLProtocol.self, at: 0)
        client = BoxCastClient(configuration: configuration)
    }
    
    func testGetBroadcastView() {
        let data = "{\"playlist\": \"https://api.boxcast.com/playlist\", \"status\": \"live\"}".data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetLiveBroadcasts")
        var broadcastView: BroadcastView?
        client?.getBroadcastView(broadcastId: "1") { view, error in
            broadcastView = view
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertEqual(broadcastView?.playlistURL, URL(string: "https://api.boxcast.com/playlist")!)
            XCTAssertEqual(broadcastView?.status, .live)
        }
    }
    
}
