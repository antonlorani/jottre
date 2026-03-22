@MainActor
final class EnableCloudViewModel: Sendable {

    private weak var coordinator: EnableCloudCoordinator?

    private(set) lazy var actions: [CallToActionStackView.ButtonConfiguration] = [
        .init(style: .primary, title: "Learn How To Enable", icon: "arrow.up.forward", action: { [weak self] in
            self?.didTapLearnHowToEnable()
        }),
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
