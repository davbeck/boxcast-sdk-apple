import Foundation

public extension BoxCastClient {
	// MARK: - Accessing Broadcast Views

	/// Returns a view for a specific broadcast.
	///
	/// - Parameters:
	///   - broadcastId: The broadcast id.
	///   - completionHandler: The handler to be called upon completion.
	func getBroadcastView(broadcastId: String, completionHandler: @escaping ((BroadcastView?, Error?) -> Void)) {
		getJSON(for: "/broadcasts/\(broadcastId)/view") { json, error in
			if let json {
				do {
					let broadcastView = try BroadcastView(json: json)
					completionHandler(broadcastView, nil)
				} catch {
					completionHandler(nil, error)
				}
			} else {
				completionHandler(nil, error ?? BoxCastError.unknown)
			}
		}
	}
	
	/// Returns a view for a specific broadcast.
	/// - Parameter broadcastId: The broadcast id.
	/// - Returns: The broadcast view info.
	@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
	func getBroadcastView(broadcastId: String) async throws -> BroadcastView {
		try await withCheckedThrowingContinuation { continuation in
			getBroadcastView(broadcastId: broadcastId) { list, error in
				if let error {
					continuation.resume(throwing: error)
				} else if let list {
					continuation.resume(returning: list)
				} else {
					assertionFailure("invalid callback response")
				}
			}
		}
	}
}
