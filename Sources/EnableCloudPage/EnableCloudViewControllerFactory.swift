import UIKit

@MainActor
protocol EnableCloudViewControllerFactory: Sendable {

    func make(coordinator: EnableCloudCoordinator) -> UIViewController
}

struct IOS18EnableCloudViewControllerFactory: EnableCloudViewControllerFactory {

    func make(coordinator: EnableCloudCoordinator) -> UIViewController {
        PageViewController(
            viewModel: EnableCloudViewModel(
                coordinator: coordinator
            ),
            textBarButtonItemFactory: IOS18TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS18SymbolBarButtonItemFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26EnableCloudViewControllerFactory: EnableCloudViewControllerFactory {

    func make(coordinator: EnableCloudCoordinator) -> UIViewController {
        PageViewController(
            viewModel: EnableCloudViewModel(
                coordinator: coordinator
            ),
            textBarButtonItemFactory: IOS26TextBarButtonItemFactory(),
            symbolBarButtonItemFactory: IOS26SymbolBarButtonItemFactory()
        )
    }
}
