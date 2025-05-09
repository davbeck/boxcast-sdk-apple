import XCTest
@testable import BoxCast

class ErrorsTests: MockedClientTestCase {
	func testGetBroadcastReturnsNotFound() {
		let data = (
			"{" +
				"\"error\":\"not_found\"" +
				"}"
		).data(using: .utf8)
		MockedURLProtocol.mockedData = data
		MockedURLProtocol.mockedStatusCode = 404

		let expectation = self.expectation(description: "GetBroadcastReturnsNotFound")
		var error: Error?
		client.getBroadcast(broadcastId: "1", channelId: "2") { b, e in
			error = e
			expectation.fulfill()
		}
		waitForExpectations(timeout: 1) { _ in
			XCTAssertNotNil(error)
			XCTAssertEqual(error as? BoxCastError, BoxCastError.notFound)
		}
	}
}
