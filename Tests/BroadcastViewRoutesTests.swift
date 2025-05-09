import XCTest
@testable import BoxCast

class BroadcastViewRoutesTests: MockedClientTestCase {
	func testGetBroadcastView() {
		guard let data = fixtureData(for: "View") else {
			XCTFail("no fixture data")
			return
		}
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
