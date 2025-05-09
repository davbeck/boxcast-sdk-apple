import Foundation

extension String {
	func stringByAddingPercentEncodingForRFC3986() -> String? {
		let unreserved = "-._~/?"
		var allowed = CharacterSet.alphanumerics
		allowed.insert(charactersIn: unreserved)
		return addingPercentEncoding(withAllowedCharacters: allowed)
	}
}
