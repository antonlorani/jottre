import UIKit

final class RootViewController: UIViewController {
    
    private let viewModel: RootViewModel
    
    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Jottre"
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .systemBackground
    }
}
