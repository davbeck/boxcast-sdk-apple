import Foundation

class InfoPlist {
	static var boxCastSDKVersion: String {
		boxCastSDKInfoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
	}

	static var appName: String {
		appInfoDictionary?["CFBundleName"] as? String ?? "Unknown"
	}

	static var appVersion: String {
		appInfoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
	}

	static var appBuild: String {
		appInfoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
	}

	static var appBundleIndentifier: String {
		appInfoDictionary?["CFBundleIdentifier"] as? String ?? "Unknown"
	}

	static var appInfoDictionary: [String: Any]? {
		Bundle.main.infoDictionary
	}

	static var boxCastSDKInfoDictionary: [String: Any]? {
		Bundle(for: InfoPlist.self).infoDictionary
	}
}
