import UIKit

@MainActor
protocol PageViewModel: AnyObject {
    var leftNavigationItems: AsyncStream<[PageNavigationItem]> { get }
    var rightNavigationItems: AsyncStream<[PageNavigationItem]> { get }
    
    var items: AsyncStream<[PageCellItem]> { get }
    var actions: [PageCallToActionView.ActionConfiguration] { get }
}

extension PageViewModel {

    var leftNavigationItems: AsyncStream<[PageNavigationItem]> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }

    var rightNavigationItems: AsyncStream<[PageNavigationItem]> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }
}
