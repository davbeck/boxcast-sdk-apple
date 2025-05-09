import XCTest
@testable import BoxCast

class QueryBuilderTests: XCTestCase {
	func testAnd() {
		let builder = QueryBuilder()
		builder.appendWithLogic(.or, key: "key", value: "this")
		builder.appendWithLogic(.and, key: "key", value: "that")
		XCTAssertEqual(builder.build(), "key:this +key:that")
	}

	func testOr() {
		let builder = QueryBuilder()
		builder.appendWithLogic(.or, key: "key", value: "this")
		builder.appendWithLogic(.or, key: "key", value: "that")
		XCTAssertEqual(builder.build(), "key:this key:that")
	}
}
