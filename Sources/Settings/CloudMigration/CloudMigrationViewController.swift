import UIKit

final class CloudMigrationViewController: UIViewController {

    private let viewModel: CloudMigrationViewModel

    init(viewModel: CloudMigrationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }
}
