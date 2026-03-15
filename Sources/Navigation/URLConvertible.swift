import Foundation

/// Allows conformances to be converted to a ``URL``.
protocol URLConvertible: Sendable {

    var scheme: String? { get }
    var host: String? { get }
    var path: String { get }

    func toURL() -> URL
}

extension URLConvertible {

    var scheme: String? {
        nil
    }

    var host: String? {
        nil
    }

    func toURL() -> URL {
        assert(path.starts(with: "/"))
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        guard let url = components.url else {
            preconditionFailure()
        }
        return url
    }
}
