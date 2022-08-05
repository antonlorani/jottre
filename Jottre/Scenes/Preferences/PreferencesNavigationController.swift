import UIKit
import Combine

final class PreferencesNavigationController: UINavigationController {

    private var userInterfaceStyleCancellable: AnyCancellable?

    init(rootViewController: PreferencesViewController, defaults: DefaultsProtocol) {
        super.init(rootViewController: rootViewController)

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
            .publisher(PreferredUserInterfaceStyleEntry())
            .replaceNil(with: UIUserInterfaceStyle.unspecified.rawValue)
            .compactMap(UIUserInterfaceStyle.init)
            .sink { [weak self] preferredUserInterfaceStyle in
                self?.view.animateTransition(newUserInterfaceStyle: preferredUserInterfaceStyle)
            }
    }
}
