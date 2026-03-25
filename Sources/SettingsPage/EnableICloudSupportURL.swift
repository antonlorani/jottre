import Foundation

struct EnableICloudSupportURL: URLConvertible {
    let scheme: String? = "https"
    let host: String? = "support.apple.com"
    let path: String

    init(locale: Locale = .current) {
        if let language = locale.languageCode,
           let region = locale.regionCode {
            path = "/\(language)-\(region.lowercased())/guide/icloud/mmfc0f1e2a/icloud"
        } else {
            path = "/guide/icloud/mmfc0f1e2a/icloud"
        }
    }
}
