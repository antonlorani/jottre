import UIKit

final class EditNoteViewController: UIViewController {
    
    private let viewModel: EditNoteViewModel

    init(viewModel: EditNoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }
}
