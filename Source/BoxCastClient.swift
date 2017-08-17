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
    
    // MARK: - Internal    
    
    func getJSON(for url: String, completionHandler: @escaping (Any?, Error?) -> Void ) {
        getJSON(for: url, parameters: nil, completionHandler: completionHandler)
    }
    
    func getJSON(for url: String, parameters: [String : Any]?, completionHandler: @escaping (Any?, Error?) -> Void) {
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
                if let data = data, let error = BoxCastError(responseData: data) {
                    DispatchQueue.main.async { completionHandler(nil, error) }
                } else {
                    DispatchQueue.main.async { completionHandler(nil, BoxCastError.unknown) }
                }
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
