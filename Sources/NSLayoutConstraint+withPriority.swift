import UIKit

extension NSLayoutConstraint {

    @inline(__always)
    func withPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return `self`
    }
}
