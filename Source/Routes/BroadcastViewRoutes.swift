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
}
