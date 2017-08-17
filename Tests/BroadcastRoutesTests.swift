//
//  BroadcastRoutesTests.swift
//  BoxCast
//
//  Created by Camden Fullmer on 8/17/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import XCTest
@testable import BoxCast

class BroadcastRoutesTests: XCTestCase {
    
    var client: BoxCastClient?
    
    override func setUp() {
        super.setUp()
        
        // Set up mocking of the responses.
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses?.insert(MockedURLProtocol.self, at: 0)
        client = BoxCastClient(configuration: configuration)
    }
    
    func testGetLiveBroadcasts() {
        let data = (
            "[{" +
                "\"id\":\"1\"," +
                "\"name\": \"Test\"," +
                "\"description\":\"A test broadcast.\"," +
                "\"account_id\":\"1\"," +
                "\"channel_id\":\"1\"," +
                "\"preview\": \"https://api.boxcast.com/thumbnail.jpg\"," +
                "\"starts_at\": \"2017-07-28T22:00:00Z\"," +
                "\"stops_at\": \"2017-07-28T23:00:00Z\"" +
            "}]"
            ).data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetLiveBroadcasts")
        var liveBroadcasts: BroadcastList?
        client?.getLiveBroadcasts(channelId: "1") { broadcasts, error in
            liveBroadcasts = broadcasts
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertNotNil(liveBroadcasts)
            XCTAssertEqual(liveBroadcasts?.count, 1)
        }
    }
    
    func testGetArchivedBroadcasts() {
        let data = (
            "[{" +
                "\"id\":\"1\"," +
                "\"name\": \"Test\"," +
                "\"description\":\"A test broadcast.\"," +
                "\"account_id\":\"1\"," +
                "\"channel_id\":\"1\"," +
                "\"preview\": \"https://api.boxcast.com/thumbnail.jpg\"," +
                "\"starts_at\": \"2017-07-28T22:00:00Z\"," +
                "\"stops_at\": \"2017-07-28T23:00:00Z\"" +
            "}]"
            ).data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetArchivedBroadcasts")
        var archivedBroadcasts: BroadcastList?
        client?.getArchivedBroadcasts(channelId: "1") { broadcasts, error in
            archivedBroadcasts = broadcasts
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertNotNil(archivedBroadcasts)
            XCTAssertEqual(archivedBroadcasts?.count, 1)
        }
    }
    
    func testGetBroadcast() {
        let formatter = BoxCastDateFormatter()
        let startDate = formatter.date(from: "2017-07-28T22:00:00Z")!
        let stopDate = formatter.date(from: "2017-07-28T23:00:00Z")!
        let data = (
            "{" +
                "\"id\":\"1\"," +
                "\"name\": \"Test\"," +
                "\"description\":\"A test broadcast.\"," +
                "\"account_id\":\"1\"," +
                "\"channel_id\":\"1\"," +
                "\"preview\": \"https://api.boxcast.com/thumbnail.jpg\"," +
                "\"starts_at\": \"2017-07-28T22:00:00Z\"," +
                "\"stops_at\": \"2017-07-28T23:00:00Z\"" +
            "}"
            ).data(using: .utf8)
        MockedURLProtocol.mockedData = data
        
        let expectation = self.expectation(description: "GetLiveBroadcasts")
        var broadcast: Broadcast?
        client?.getBroadcast(broadcastId: "1", channelId: "2") { b, error in
            broadcast = b
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            XCTAssertNotNil(broadcast)
            XCTAssertEqual(broadcast?.id, "1")
            XCTAssertEqual(broadcast?.accountId, "1")
            XCTAssertEqual(broadcast?.channelId, "2")
            XCTAssertEqual(broadcast?.name, "Test")
            XCTAssertEqual(broadcast?.description, "A test broadcast.")
            XCTAssertEqual(broadcast?.thumbnailURL, URL(string: "https://api.boxcast.com/thumbnail.jpg")!)
            XCTAssertTrue(broadcast?.startDate.compare(startDate) == .orderedSame)
            XCTAssertTrue(broadcast?.stopDate.compare(stopDate) == .orderedSame)
        }
    }
    
}
