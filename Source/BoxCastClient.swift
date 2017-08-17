//
//  BoxCastClient.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation

/// The client for the BoxCast API. Use the client to access resources of the BoxCast ecosystem.
public class BoxCastClient {
    
    let apiURL = "https://api.boxcast.com"
    let session: URLSession
    
    private enum Timeframe: String {
        case live = "current"
        case past = "past"
    }
    
    // MARK: - Shared Instance
    
    /// The shared singleton object to be used for accessing resources.
    public static let shared = BoxCastClient()
    
    internal convenience init() {
        let configuration = URLSessionConfiguration.default
        self.init(configuration: configuration)
    }
    
    internal init(configuration: URLSessionConfiguration) {
        session = URLSession(configuration: configuration)
    }
    
    // MARK: - Accessing Resources
    
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
    
    /// Returns a view for a specific broadcast.
    ///
    /// - Parameters:
    ///   - broadcastId: The broadcast id.
    ///   - completionHandler: The handler to be called upon completion.
    public func getBroadcastView(broadcastId: String, completionHandler: @escaping ((BroadcastView?, Error?) -> Void)) {
        getJSON(for: "\(apiURL)/broadcasts/\(broadcastId)/view") { (json, error) in
            if let json = json {
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
    
    private func getJSON(for url: String, completionHandler: @escaping (Any?, Error?) -> Void ) {
        getJSON(for: url, parameters: nil, completionHandler: completionHandler)
    }
    
    private func getJSON(for url: String, parameters: [String : Any]?, completionHandler: @escaping (Any?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            return completionHandler(nil, BoxCastError.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if let parameters = parameters {
            do {
                let data = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
                request.httpBody = data
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completionHandler(nil, error)
            }
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async { completionHandler(nil, error) }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(nil, BoxCastError.unknown) }
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                // TODO parse JSON for error object.
                DispatchQueue.main.async { completionHandler(nil, BoxCastError.unknown) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completionHandler(nil, BoxCastError.unknown) }
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                DispatchQueue.main.async { completionHandler(json, nil) }
            } catch {
                DispatchQueue.main.async { completionHandler(nil, error) }
            }
            
        }
        task.resume()
    }
}
