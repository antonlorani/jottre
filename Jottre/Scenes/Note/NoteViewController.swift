import UIKit

final class NoteViewController: UIViewController {

    private struct Constants {
        struct ExportNoteBarButton {
            static let systemName = "square.and.arrow.up"
        }
    }

    private let viewModel: NoteViewModel

    init(viewModel: NoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setUpNavigationBar()
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Hello, World!"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.ExportNoteBarButton.systemName),
            style: .plain,
            target: self,
            action: #selector(exportNoteDidTap(_:))
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground
    }

    @objc private func exportNoteDidTap(_ sender: UIBarButtonItem) {
        viewModel.exportNoteDidTap()
    }
}
