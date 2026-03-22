@MainActor
final class EnableCloudViewModel: Sendable {

    private weak var coordinator: EnableCloudCoordinator?

    let pageHeaderConfiguration = PageHeaderView.Configuration(
        headline: "Enable iCloud",
        subheadline: "It looks like iCloud is disabled on this device. Turn on iCloud to get the most out of Jottre."
    )

    private(set) lazy var actions = [
        PageCallToActionView.ActionConfiguration(
            style: .primary,
            title: "Learn How To Enable",
            icon: "arrow.up.forward"
        ) { [weak self] in
            self?.didTapLearnHowToEnable()
        },
    ]

    init(coordinator: EnableCloudCoordinator) {
        self.coordinator = coordinator
    }

    func didTapCloseButton() {
        coordinator?.dismiss()
    }

    private func didTapLearnHowToEnable() {
        coordinator?.openLearnHowToEnable()
    }
}
