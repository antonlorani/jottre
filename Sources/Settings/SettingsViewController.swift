import UIKit

final class SettingsViewController: UIViewController {

    private let viewModel: SettingsViewModel
    private let closeBarButtonItemFactory: BarButtonItemFactory

    init(
        viewModel: SettingsViewModel,
        closeBarButtonItemFactory: BarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.closeBarButtonItemFactory = closeBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationItem()
    }

    private func setUpNavigationItem() {
        navigationItem.title = "Settings"

        navigationItem.leftBarButtonItem = closeBarButtonItemFactory.make(
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapCloseButton()
            }
        )
    }
}
