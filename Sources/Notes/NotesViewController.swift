import UIKit

final class NotesViewController: UIViewController {

    private enum Constants {

        enum CollectionViewFlowLayout {
            static let inset = CGFloat(16)
            static let spacing = CGFloat(8)
            static let minimumCellWidth = CGFloat(160)
        }
    }

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = Constants.CollectionViewFlowLayout.spacing
        flowLayout.minimumLineSpacing = Constants.CollectionViewFlowLayout.spacing
        flowLayout.sectionInsetReference = .fromLayoutMargins
        return flowLayout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = view.backgroundColor
        collectionView.preservesSuperviewLayoutMargins = true
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var emptyStateConstraints = [
        emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        emptyStateLabel.widthAnchor
            .constraint(lessThanOrEqualTo: view.widthAnchor, constant: -(Constants.CollectionViewFlowLayout.inset * 2)),
        emptyStateLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
    ]

    private lazy var filledStateConstraints = [
        collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    private var stateTask: Task<Void, Never>?
    private var items = [NotesViewModel.State.Item]()

    private let viewModel: NotesViewModel
    private let symbolBarButtonItemFactory: SymbolBarButtonItemFactory
    private let textBarButtonItemFactory: TextBarButtonItemFactory

    init(
        viewModel: NotesViewModel,
        symbolBarButtonItemFactory: SymbolBarButtonItemFactory,
        textBarButtonItemFactory: TextBarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.symbolBarButtonItemFactory = symbolBarButtonItemFactory
        self.textBarButtonItemFactory = textBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)

        stateTask = Task { [weak self] in
            for await state in viewModel.state {
                self?.handleState(state: state)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    deinit {
        stateTask?.cancel()
    }

    override func viewDidLoad() {
        setUpNavigationItem()
        setUpViews()

        super.viewDidLoad()
    }

    private func setUpNavigationItem() {
#if !targetEnvironment(macCatalyst)
        navigationItem.title = "Jottre"
        navigationItem.largeTitleDisplayMode = .automatic
#else
        navigationItem.largeTitleDisplayMode = .never
#endif
        
        navigationItem.leftBarButtonItems = [
            symbolBarButtonItemFactory.make(
                symbolName: "gear",
                primaryAction: .action(
                    UIAction { [weak self] _ in
                        self?.viewModel.didTapSettingsButton()
                    }
                )
            ),
            symbolBarButtonItemFactory.make(
                symbolName: "icloud.slash",
                primaryAction: .action(
                    UIAction { [weak self] _ in
                        self?.viewModel.didTapEnableCloudButton()
                    }
                )
            )
        ]
        navigationItem.rightBarButtonItem = textBarButtonItemFactory.make(
            title: "Create",
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapCreateNoteButton()
            }
        )
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionViewLayout.invalidateLayout()
        })
    }

    private func setUpViews() {
        view.backgroundColor = .systemGroupedBackground
    }

    private func handleState(state: NotesViewModel.State) {
        switch state {
        case let .filled(items):
            assert(!items.isEmpty, "An empty items state MUST be represented as 'NotesViewModel.State.empty'.")
            handleFilledState(items: items)
        case let .empty(title):
            handleEmptyState(title: title)
        }
    }

    private func handleFilledState(items: [NotesViewModel.State.Item]) {
        self.items = items
        collectionView.reloadData()

        guard collectionView.superview == nil else {
            return
        }
        emptyStateLabel.removeFromSuperview()
        view.addSubview(collectionView)
        NSLayoutConstraint.deactivate(emptyStateConstraints)
        NSLayoutConstraint.activate(filledStateConstraints)
    }

    private func handleEmptyState(title: String) {
        items.removeAll()

        guard emptyStateLabel.superview == nil else {
            return
        }
        emptyStateLabel.text = title
        collectionView.removeFromSuperview()
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.deactivate(filledStateConstraints)
        NSLayoutConstraint.activate(emptyStateConstraints)
    }
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = items[safe: indexPath.row] else {
            return UICollectionViewCell()
        }

        return makeNoteCell(
            note: item.note,
            indexPath: indexPath
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let item = items[safe: indexPath.row] else {
            return nil
        }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            UIMenu.make(noteMenuConfigurations: item.menuConfigurations)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = Constants.CollectionViewFlowLayout.spacing
        let minWidth = Constants.CollectionViewFlowLayout.minimumCellWidth
        let available = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        let columns = max(1, floor((available + spacing) / (minWidth + spacing)))
        let width = (available - spacing * (columns - 1)) / columns
        return CGSize(width: width, height: width * 1.1)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        items[safe: indexPath.row]?.onAction()
    }

    private func makeNoteCell(
        note: NoteBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NoteCell.reuseIdentifier,
            for: indexPath
        ) as? NoteCell else {
            return UICollectionViewCell()
        }
        cell.configure(
            note: note,
            infoText: nil
        )
        return cell
    }
}
