import Foundation

public extension BoxCastClient {
	private enum Timeframe: String {
		case upcoming = "future"
		case live = "current"
		case preroll = "preroll"
		case past = "past"
	}

	// MARK: - Accessing Broadcasts

	/// Returns a list of upcoming broadcasts for a specific channel.
	///
	/// - Parameters:
	///   - channelId: The channel id.
	///   - completionHandler: The handler to be called upon completion.
	func getUpcomingBroadcasts(channelId: String, completionHandler: @escaping (@Sendable (BroadcastList?, Error?) -> Void)) {
		findBroadcasts(channelId: channelId, timeframes: [.upcoming], completionHandler: completionHandler)
	}

	/// Returns a list of live broadcasts for a specific channel.
	///
	/// - Parameters:
	///   - channelId: The channel id.
	@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
	func getUpcomingBroadcasts(channelId: String) async throws -> BroadcastList {
		try await withCheckedThrowingContinuation { continuation in
			getUpcomingBroadcasts(channelId: channelId) { list, error in
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

	/// Returns a list of live broadcasts for a specific channel.
	///
	/// - Parameters:
	///   - channelId: The channel id.
	///   - completionHandler: The handler to be called upon completion.
	func getLiveBroadcasts(channelId: String, completionHandler: @escaping (@Sendable (BroadcastList?, Error?) -> Void)) {
		findBroadcasts(channelId: channelId, timeframes: [.live, .preroll], completionHandler: completionHandler)
	}

	/// Returns a list of live broadcasts for a specific channel.
	///
	/// - Parameters:
	///   - channelId: The channel id.
	@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
	func getLiveBroadcasts(channelId: String) async throws -> BroadcastList {
		try await withCheckedThrowingContinuation { continuation in
			getLiveBroadcasts(channelId: channelId) { list, error in
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

	/// Returns a list of archived broadcasts for a specific channel.
	///
	/// - Parameters:
	///   - channelId: The channel id.
	///   - completionHandler: The handler to be called upon completion.
	func getArchivedBroadcasts(channelId: String, completionHandler: @escaping (@Sendable (BroadcastList?, Error?) -> Void)) {
		findBroadcasts(channelId: channelId, timeframes: [.past], completionHandler: completionHandler)
	}

	/// Returns a list of archived broadcasts for a specific channel.
	/// - Parameter channelId: The channel id.
	/// - Returns: The list of archived broadcasts.
	@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
	func getArchivedBroadcasts(channelId: String) async throws -> BroadcastList {
		try await withCheckedThrowingContinuation { continuation in
			getArchivedBroadcasts(channelId: channelId) { list, error in
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

	/// Returns a detailed broadcast.
	///
	/// - Parameters:
	///   - broadcastId: The broadcast id.
	///   - channelId: The channel id.
	///   - completionHandler: The handler to be called upon completion.
	func getBroadcast(broadcastId: String, channelId: String, completionHandler: @escaping (@Sendable (Broadcast?, Error?) -> Void)) {
		getJSON(for: "/broadcasts/\(broadcastId)") { json, error in
			if let json {
				do {
					let broadcast = try Broadcast(channelId: channelId, json: json)
					completionHandler(broadcast, nil)
				} catch {
					completionHandler(nil, error)
				}
			} else {
				completionHandler(nil, error ?? BoxCastError.unknown)
			}
		}
	}

	/// Returns a detailed broadcast.
	/// - Parameters:
	///   - broadcastId: The broadcast id.
	///   - channelId: The channel id.
	/// - Returns: The handler to be called upon completion.
	@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
	func getBroadcast(broadcastId: String, channelId: String) async throws -> Broadcast {
		try await withCheckedThrowingContinuation { continuation in
			getBroadcast(broadcastId: broadcastId, channelId: channelId) { list, error in
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

	// MARK: - Private

	private func findBroadcasts(
		channelId: String, timeframes: [Timeframe],
		completionHandler: @escaping (@Sendable ([Broadcast]?, Error?) -> Void)
	) {
		// Build the query.
		let query = QueryBuilder()
		for t in timeframes {
			query.appendWithLogic(.or, key: "timeframe", value: t.rawValue)
		}
		let params = [
			"q": query.build(),
		]
		getJSON(for: "/channels/\(channelId)/broadcasts", parameters: params) { json, error in
			if let json {
				do {
					let broadcastList = try BroadcastList(channelId: channelId, json: json)
					completionHandler(broadcastList, nil)
				} catch {
					completionHandler(nil, error)
				}
			} else {
				completionHandler(nil, error ?? BoxCastError.unknown)
			}
		}
	}
}
