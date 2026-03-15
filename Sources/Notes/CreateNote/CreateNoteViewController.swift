import UIKit

final class CreateNoteViewController: UIViewController {

    private let viewModel: CreateNoteViewModel

    init(viewModel: CreateNoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }
}
