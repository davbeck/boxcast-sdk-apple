import Foundation

public struct PublicScope: BoxCastScopable {
	public init() {}

	public var apiURL: String {
		"https://api.boxcast.com"
	}

	public var additionalHeaders: [String: String]? {
		nil
	}
}

public protocol BoxCastScopable {
	var apiURL: String { get }
	var additionalHeaders: [String: String]? { get }
}

/// The client for the BoxCast API. Use the client to access resources of the BoxCast ecosystem.
///
/// Make sure to call `BoxCastClient.setUp()` before using the `sharedClient`.
public class BoxCastClient {
	let session: URLSession
	let scope: BoxCastScopable

	public init(scope: BoxCastScopable, configuration: URLSessionConfiguration = .default) {
		self.scope = scope
		session = URLSession(configuration: configuration)
	}

	// MARK: - Request

	public func getJSON(for path: String, parameters: [String: Any]? = nil, completionHandler: @Sendable @escaping (Any?, Error?) -> Void) {
		requestJSON(
			for: path, method: "GET", parameters: parameters,
			completionHandler: completionHandler
		)
	}

	public func postJSON(for path: String, parameters: [String: Any]?, completionHandler: @Sendable @escaping (Any?, Error?) -> Void) {
		requestJSON(
			for: path, method: "POST", parameters: parameters,
			completionHandler: completionHandler
		)
	}

	public func putJSON(for path: String, parameters: [String: Any], completionHandler: @Sendable @escaping (Any?, Error?) -> Void) {
		requestJSON(
			for: path, method: "PUT", parameters: parameters,
			completionHandler: completionHandler
		)
	}

	public func post(path: String, parameters: [String: Any], completionHandler: @Sendable @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
		request(
			url: "\(scope.apiURL)\(path)", method: "POST", parameters: parameters,
			completionHandler: completionHandler
		)
	}

	public func get(path: String, parameters: [String: Any], completionHandler: @Sendable @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
		request(
			url: "\(scope.apiURL)\(path)", method: "GET", parameters: parameters,
			completionHandler: completionHandler
		)
	}

	public func delete(path: String, completionHandler: @Sendable @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
		request(
			url: "\(scope.apiURL)\(path)", method: "DELETE", parameters: nil,
			completionHandler: completionHandler
		)
	}

	private func requestJSON(for path: String, method: String, parameters: [String: Any]?, completionHandler: @Sendable @escaping (Any?, Error?) -> Void) {
		request(url: "\(scope.apiURL)\(path)", method: method, parameters: parameters) { response, data, error in
			if let error {
				completionHandler(nil, error)
				return
			}
			guard let data else {
				completionHandler(nil, BoxCastError.unknown)
				return
			}
			do {
				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
				completionHandler(json, nil)
			} catch {
				completionHandler(nil, error)
			}
		}
	}

	private func request(url: String, method: String, parameters: [String: Any]?, completionHandler: @Sendable @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
		guard let url = URL(string: url) else {
			return completionHandler(nil, nil, BoxCastError.invalidURL)
		}

		var request = URLRequest(url: url)
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.httpMethod = method

		do {
			if let parameters {
				if method == "GET" {
					let encodedParameters = parameters.mapValues { "\($0)".stringByAddingPercentEncodingForRFC3986() ?? "" }
					let query = encodedParameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
					var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
					urlComponents?.percentEncodedQuery = query
					request.url = urlComponents?.url
				} else {
					let data = try JSONSerialization.data(withJSONObject: parameters,
					                                      options: .prettyPrinted)
					request.httpBody = data
					request.setValue("application/json", forHTTPHeaderField: "Content-Type")
				}
			}
		} catch {
			completionHandler(nil, nil, error)
		}
		if let headers = scope.additionalHeaders {
			for (key, value) in headers {
				request.setValue(value, forHTTPHeaderField: key)
			}
		}
		let task = session.dataTask(with: request) { data, response, error in
			guard error == nil else {
				completionHandler(nil, nil, error)
				return
			}
			guard let response = response as? HTTPURLResponse else {
				completionHandler(nil, nil, BoxCastError.unknown)
				return
			}
			guard response.statusCode >= 200 && response.statusCode < 300 else {
				if let data, let error = BoxCastError(responseData: data) {
					completionHandler(response, nil, error)
				} else {
					completionHandler(response, nil, BoxCastError.unknown)
				}
				return
			}
			completionHandler(response, data, nil)
		}
		task.resume()
	}
}
