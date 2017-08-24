//
//  BoxCastClient.swift
//  BoxCast
//
//  Created by Camden Fullmer on 5/13/17.
//  Copyright © 2017 BoxCast, Inc. All rights reserved.
//

import Foundation

public struct PublicScope: BoxCastScopable {
    public var isAuthorized: Bool {
        return true
    }
}

public protocol BoxCastScopable {
    var isAuthorized: Bool { get }
}

/// The client for the BoxCast API. Use the client to access resources of the BoxCast ecosystem.
public class BoxCastClient {
    
    public let apiURL = "https://api.boxcast.com"
    let session: URLSession
    
    // MARK: - Setup
    
    public static func setUp(scope: BoxCastScopable = PublicScope()) {
        
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
    
    // MARK: - Request
    
    public func getJSON(for url: String, parameters: [String : Any]? = nil, completionHandler: @escaping (Any?, Error?) -> Void) {
        requestJSON(for: url, method: "GET", parameters: parameters,
                    completionHandler: completionHandler)
    }
    
    public func postJSON(for url: String, parameters: [String : Any], completionHandler: @escaping (Any?, Error?) -> Void) {
        requestJSON(for: url, method: "POST", parameters: parameters,
                    completionHandler: completionHandler)
    }
    
    public func putJSON(for url: String, parameters: [String : Any], completionHandler: @escaping (Any?, Error?) -> Void) {
        requestJSON(for: url, method: "PUT", parameters: parameters,
                    completionHandler: completionHandler)
    }
    
    public func post(url: String, parameters: [String : Any], completionHandler: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
        request(url: url, method: "POST", parameters: parameters,
                completionHandler: completionHandler)
    }
    
    public func get(url: String, parameters: [String : Any], completionHandler: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
        request(url: url, method: "GET", parameters: parameters,
                completionHandler: completionHandler)
    }
    
    private func requestJSON(for url: String, method: String, parameters: [String : Any]?, completionHandler: @escaping (Any?, Error?) -> Void) {
        request(url: url, method: method, parameters: parameters) { (response, data, error) in
            if let error = error {
                completionHandler(nil, error)
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
    }
    
    private func request(url: String, method: String, parameters: [String : Any]?, completionHandler: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            return completionHandler(nil, nil, BoxCastError.invalidURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            if let parameters = parameters {
                let data = try JSONSerialization.data(withJSONObject: parameters,
                                                      options: .prettyPrinted)
                request.httpMethod = method
                request.httpBody = data
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            completionHandler(nil, nil, error)
        }
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.async { completionHandler(nil, nil, error) }
                return
            }
            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completionHandler(nil, nil, BoxCastError.unknown) }
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                if let data = data, let error = BoxCastError(responseData: data) {
                    DispatchQueue.main.async { completionHandler(response, nil, error) }
                } else {
                    DispatchQueue.main.async { completionHandler(response, nil, BoxCastError.unknown) }
                }
                return
            }
            DispatchQueue.main.async { completionHandler(response, data, nil) }
        }
        task.resume()
    }
}
