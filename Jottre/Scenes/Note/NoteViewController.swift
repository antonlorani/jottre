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

        setUpNavigationBar(navigationTitle: viewModel.navigationTitle)
        setUpViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpNavigationBar(
        navigationTitle: String
    ) {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = navigationTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.ExportNoteBarButton.systemName),
            style: .plain,
            target: self,
            action: #selector(didClickExportNote(_:))
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground
    }

    @objc private func didClickExportNote(_ sender: UIBarButtonItem) {
        viewModel.didClickExportNote()
    }
}
