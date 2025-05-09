import XCTest
@testable import BoxCast

class DeviceTests: XCTestCase {
	func testModelIdentifier() {
		XCTAssertNotEqual(Device.modelIdentifierString, "Unknown")
	}
}
