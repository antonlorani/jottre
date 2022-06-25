import Foundation

protocol DefaultsValue {}

extension Data: DefaultsValue {}
extension String: DefaultsValue {}
extension Dictionary: DefaultsValue where Key: DefaultsValue, Value: DefaultsValue {}
extension Array: DefaultsValue where Element: DefaultsValue {}
extension Bool: DefaultsValue {}
extension Double: DefaultsValue {}
extension Float: DefaultsValue {}
extension Int: DefaultsValue {}
extension Date: DefaultsValue {}
extension URL: DefaultsValue {}
