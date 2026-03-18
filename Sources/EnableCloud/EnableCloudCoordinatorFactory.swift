@MainActor
protocol EnableCloudCoordinatorFactory: Sendable {

    func make(navigation: Navigation) -> NavigationCoordinator
}

struct IOS18EnableCloudCoordinatorFactory: EnableCloudCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        EnableCloudCoordinator(
            navigation: navigation,
            enableCloudViewControllerFactory: IOS18EnableCloudViewControllerFactory()
        )
    }
}

@available(iOS 26, *)
struct IOS26EnableCloudCoordinatorFactory: EnableCloudCoordinatorFactory {

    func make(navigation: Navigation) -> NavigationCoordinator {
        EnableCloudCoordinator(
            navigation: navigation,
            enableCloudViewControllerFactory: IOS26EnableCloudViewControllerFactory()
        )
    }
}
