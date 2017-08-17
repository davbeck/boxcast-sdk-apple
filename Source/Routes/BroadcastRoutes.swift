//
//  BroadcastRoutes.swift
//  BoxCast
//
//  Created by Camden Fullmer on 8/17/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation

extension BoxCastClient {
    
    private enum Timeframe: String {
        case live = "current"
        case past = "past"
    }
    
    // MARK: - Accessing Broadcasts
    
    /// Returns a list of live broadcasts for a specific channel.
    ///
    /// - Parameters:
    ///   - channelId: The channel id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getLiveBroadcasts(channelId: String, completionHandler: @escaping ((BroadcastList?, Error?) -> Void)) {
        findBroadcasts(channelId: channelId, timeframe: .live, completionHandler: completionHandler)
    }
    
    /// Returns a list of archived broadcasts for a specific channel.
    ///
    /// - Parameters:
    ///   - channelId: The channel id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getArchivedBroadcasts(channelId: String, completionHandler: @escaping ((BroadcastList?, Error?) -> Void)) {
        findBroadcasts(channelId: channelId, timeframe: .past, completionHandler: completionHandler)
    }
    
    /// Returns a detailed broadcast.
    ///
    /// - Parameters:
    ///   - broadcastId: The broadcast id.
    ///   - channelId: The channel id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getBroadcast(broadcastId: String, channelId: String, completionHandler: @escaping ((Broadcast?, Error?) -> Void)) {
        getJSON(for: "\(apiURL)/broadcasts/\(broadcastId)") { (json, error) in
            if let json = json {
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
    
    // MARK: - Private
    
    private func findBroadcasts(channelId: String, timeframe: Timeframe,
                                completionHandler: @escaping (([Broadcast]?, Error?) -> Void)) {
        // Build the query.
        let query = QueryBuilder()
        query.appendWithLogic(.or, key: "timeframe", value: timeframe.rawValue)
        let params = [
            "q" : query.build()
        ]
        getJSON(for: "\(apiURL)/channels/\(channelId)/broadcasts", parameters: params) { (json, error) in
            if let json = json {
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
