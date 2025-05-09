import Foundation

class System {
	static var osVersion: String {
		let version = ProcessInfo.processInfo.operatingSystemVersion
		return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
	}

	static var osName: String {
		{
			#if os(iOS)
				return "iOS"
			#elseif os(watchOS)
				return "watchOS"
			#elseif os(tvOS)
				return "tvOS"
			#elseif os(macOS)
				return "OS X"
			#elseif os(Linux)
				return "Linux"
			#else
				return "Unknown"
			#endif
		}()
	}
}
