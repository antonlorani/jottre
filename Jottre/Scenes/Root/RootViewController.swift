import UIKit

final class RootViewController: UIViewController {

    private struct Constants {
        struct InfoText {
            static let width = CGFloat(300)
            static let minHeight = CGFloat(20)
        }

        struct CollectionView {
            static let spacing = CGFloat(20)
            static let sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
            static let minWidth = CGFloat(232)
            static let height = CGFloat(291)
        }
    }

    private lazy var infoTextView: InfoTextView = {
        let infoTextView = InfoTextView(
            viewModel: InfoTextViewModel(
                repository: InfoTextViewRepository(
                    environmentDataSource: EnvironmentDataSource(
                        defaults: Defaults.shared,
                        cloudDataSource: CloudDataSource.shared,
                        deviceDataSource: DeviceDataSource.shared
                    ),
                    localizableStringsDataSource: viewModel.localizableStringsDataSource
                )
            )
        )
        infoTextView.translatesAutoresizingMaskIntoConstraints = false
        infoTextView.alpha = 0
        return infoTextView
    }()

    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = Constants.CollectionView.sectionInset
        collectionViewLayout.minimumLineSpacing = Constants.CollectionView.spacing
        collectionViewLayout.minimumInteritemSpacing = Constants.CollectionView.spacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.reuseIdentifier)
        return collectionView
    }()

    private let items: [RootViewModel.Item]
    private let viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        items = viewModel.items
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpNavigationItem(
            title: viewModel.getNavigationTitle(),
            addNoteButtonTitle: viewModel.getAddNoteButtonTitle()
        )
        setUpConstraints()
        setUpDelegates()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionView.collectionViewLayout.invalidateLayout()

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

        view.addSubview(collectionView)
        view.addSubview(infoTextView)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            infoTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoTextView.widthAnchor.constraint(equalToConstant: Constants.InfoText.width),
            infoTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.InfoText.minHeight)
        ])
    }

    private func setUpDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    @objc private func addNoteButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.addNoteButtonDidTap()
    }

    @objc private func openPreferencesButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.openPreferencesButtonDidTap()
    }
}

extension RootViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]

        let cell: UICollectionViewCell
        switch item {
        case let .note(title, image, _):
            cell = makeNoteCell(
                indexPath: indexPath,
                title: title,
                image: image
            )
        }
        return cell
    }

    private func makeNoteCell(indexPath: IndexPath, title: String, image: UIImage) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCell.reuseIdentifier, for: indexPath) as? NoteCell else {
            return .init()
        }
        cell.configure(title: title, image: image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let minWidth = Constants.CollectionView.minWidth
        let widthWithSpacing = CGFloat(collectionView.frame.width - Constants.CollectionView.spacing * 2)
        let numberOfColumns = Int(widthWithSpacing / minWidth)
        let spacing = widthWithSpacing.truncatingRemainder(dividingBy: minWidth)

        let width: CGFloat
        if numberOfColumns == 1 {
            width = widthWithSpacing
        } else {
            let spacings = CGFloat(15 * numberOfColumns)
            width = minWidth + (spacing - spacings) / CGFloat(numberOfColumns)
        }

        return CGSize(width: width, height: Constants.CollectionView.height)
    }
}
