import Foundation

protocol URLConvertible {
    var scheme: String { get }
    var subdomain: String { get }
    var domain: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var fragment: String? { get }

    func asURL() -> URL
}

extension URLConvertible {

    var scheme: String { "https" }

    var subdomain: String { "www" }

    var host: String {
        "\(subdomain).\(domain)"
    }

    var queryItems: [URLQueryItem]? { nil }
    
    var fragment: String? { nil }

    func asURL() -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.fragment = fragment
        urlComponents.percentEncodedQueryItems = queryItems

        guard let url = urlComponents.url else {
            preconditionFailure("Configuration error: Could not generate URL from components \(urlComponents)")
        }
        return url
    }
}
