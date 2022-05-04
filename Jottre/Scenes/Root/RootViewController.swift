import UIKit

final class RootViewController: UIViewController {

    private struct Constants {
        struct InfoText {
            static let width = CGFloat(300)
            static let minHeight = CGFloat(20)
        }
    }

    private lazy var infoTextView: InfoTextView = {
        let infoTextView = InfoTextView(
            viewModel: InfoTextViewModel(
                repository: InfoTextViewRepository(
                    deviceEnvironmentDataSource: viewModel.deviceEnvironmentDataSource,
                    cloudDataSource: viewModel.cloudDataSource,
                    localizableStringsDataSource: viewModel.localizableStringsDataSource
                )
            )
        )
        infoTextView.translatesAutoresizingMaskIntoConstraints = false
        return infoTextView
    }()

    private let viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpNavigationItem(
            title: viewModel.getNavigationTitle(),
            addNoteButtonTitle: viewModel.getAddNoteButtonTitle()
        )
        setUpConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    private func setUpNavigationItem(
        title: String,
        addNoteButtonTitle: String?
    ) {
        navigationItem.title = title

        if let addNoteButtonTitle = addNoteButtonTitle {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                customView: NavigationTextButton(title: addNoteButtonTitle, target: self, action: #selector(addNoteButtonDidTap(_:)))
            )
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: SettingsButton(
                target: self,
                action: #selector(openPreferencesButtonDidTap(_:))
            )
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground

        view.addSubview(infoTextView)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            infoTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoTextView.widthAnchor.constraint(equalToConstant: Constants.InfoText.width),
            infoTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.InfoText.minHeight)
        ])
    }

    @objc private func addNoteButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.addNoteButtonDidTap()
    }

    @objc private func openPreferencesButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.openPreferencesButtonDidTap()
    }
}
