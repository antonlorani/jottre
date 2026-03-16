@MainActor
final class EnableCloudViewModel: Sendable {

    private weak var coordinator: EnableCloudCoordinator?

    init(coordinator: EnableCloudCoordinator) {
        self.coordinator = coordinator
    }

    func didTapCloseButton() {
        coordinator?.dismiss()
    }

    func didTapLearnHowToEnable() {
        coordinator?.openLearnHowToEnable()
    }
}
