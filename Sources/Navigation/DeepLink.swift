import Foundation

/// Defines a ``URL`` like information, suitable for link based navigation.
struct DeepLink: Sendable {

    /// The links path.
    let path: String

    init(path: String) {
        self.path = path
    }

    /// Initializes a ``DeepLink`` from a given ``URL``.
    init(url: URL) {
        if #available(iOS 16, *) {
            path = url.path()
        } else {
            path = url.path
        }
    }
}
