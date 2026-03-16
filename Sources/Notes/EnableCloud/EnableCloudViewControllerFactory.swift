import UIKit

@MainActor
protocol EnableCloudViewControllerFactory: Sendable {

    func make(coordinator: EnableCloudCoordinator) -> UIViewController
}

struct IOS18EnableCloudViewControllerFactory: EnableCloudViewControllerFactory {

    func make(coordinator: EnableCloudCoordinator) -> UIViewController {
        EnableCloudViewController(
            viewModel: EnableCloudViewModel(coordinator: coordinator),
            closeBarButtonItemFactory: IOS18CloseBarButtonItemFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26EnableCloudViewControllerFactory: EnableCloudViewControllerFactory {

    func make(coordinator: EnableCloudCoordinator) -> UIViewController {
        EnableCloudViewController(
            viewModel: EnableCloudViewModel(coordinator: coordinator),
            closeBarButtonItemFactory: IOS26CloseBarButtonItemFactory()
        )
    }
}
