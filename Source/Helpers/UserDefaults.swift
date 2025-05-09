import Foundation

extension UserDefaults {
	static var boxCastDefaults: UserDefaults? {
		UserDefaults(suiteName: "com.boxcast.sdk-defaults")
	}
}
