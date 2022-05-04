import UIKit

final class PreferencesViewController: UIViewController {

    private let viewModel: PreferencesViewModel

    init(viewModel: PreferencesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpViews() {
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = "Preferences"
    }
}
