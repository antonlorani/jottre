/// Allows conformances to be converted to a ``DeepLink``.
protocol DeepLinkConvertible: Sendable {

    var path: String { get }

    func toDeepLink() -> DeepLink
}

extension DeepLinkConvertible {

    func toDeepLink() -> DeepLink {
        assert(path.starts(with: "/"))
        return DeepLink(path: path)
    }
}
