import UIKit
import Combine

final class PreferencesNavigationController: UINavigationController {

    private var userInterfaceStyleCancellable: AnyCancellable?

    init(defaults: DefaultsProtocol) {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        bindDefaults(defaults: defaults)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpViews() {
        navigationBar.prefersLargeTitles = true
    }

    private func bindDefaults(defaults: DefaultsProtocol) {
        userInterfaceStyleCancellable = defaults
            .publisher(\.customUserInterfaceStyle)
            .compactMap(UIUserInterfaceStyle.init)
            .sink { [weak self] customUserInterfaceStyle in
                self?.view.animateTransition(newUserInterfaceStyle: customUserInterfaceStyle)
            }
    }
}
