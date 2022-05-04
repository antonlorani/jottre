import UIKit

final class PreferencesNavigationController: UINavigationController {

    init() {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpViews() {
        navigationBar.prefersLargeTitles = true
    }
}
