import UIKit

final class PageViewController: UIViewController {

    private enum Constants {
        static let itemSpacing = CGFloat(8)
    }

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.itemSpacing
        layout.minimumLineSpacing = Constants.itemSpacing
        layout.sectionInset = .zero
        layout.sectionInsetReference = .fromLayoutMargins
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.preservesSuperviewLayoutMargins = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PageHeaderCell.self, forCellWithReuseIdentifier: PageHeaderCell.reuseIdentifier)
        collectionView.register(FeatureRowCell.self, forCellWithReuseIdentifier: FeatureRowCell.reuseIdentifier)
        collectionView.register(CloudMigrationNoteCell.self, forCellWithReuseIdentifier: CloudMigrationNoteCell.reuseIdentifier)
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var callToActionView: PageCallToActionView = {
        let view = PageCallToActionView(actions: viewModel.actions)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var sizingHeaderCell = PageHeaderCell()
    private lazy var sizingFeatureRowCell = FeatureRowCell()

    private var leftNavigationItemsTask: Task<Void, Never>?
    private var rightNavigationItemsTask: Task<Void, Never>?

    private var items = [PageItem]()
    private var itemsTask: Task<Void, Never>?

    private let viewModel: PageViewModel
    private let textBarButtonItemFactory: TextBarButtonItemFactory
    private let symbolBarButtonItemFactory: SymbolBarButtonItemFactory

    init(
        viewModel: PageViewModel,
        textBarButtonItemFactory: TextBarButtonItemFactory,
        symbolBarButtonItemFactory: SymbolBarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.textBarButtonItemFactory = textBarButtonItemFactory
        self.symbolBarButtonItemFactory = symbolBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)

        itemsTask = Task { [weak self] in
            for await items in viewModel.items {
                self?.handleItems(items)
            }
        }

        leftNavigationItemsTask = Task { [weak self] in
            for await navigationItems in viewModel.leftNavigationItems {
                self?.handleLeftNavigationItems(navigationItems: navigationItems)
            }
        }

        rightNavigationItemsTask = Task { [weak self] in
            for await navigationItems in viewModel.rightNavigationItems {
                self?.handleRightNavigationItems(navigationItems: navigationItems)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    deinit {
        itemsTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpViews()
    }

    private func handleRightNavigationItems(navigationItems: [PageNavigationItem]) {
        if let firstNavigationItem = navigationItems.first, navigationItems.count == 1 {
            navigationItem.setRightBarButton(
                makeNavigationItem(navigationItem: firstNavigationItem),
                animated: true
            )
        } else {
            navigationItem.setRightBarButtonItems(
                navigationItems.map(makeNavigationItem),
                animated: true
            )
        }
    }

    private func handleLeftNavigationItems(navigationItems: [PageNavigationItem]) {
        if let firstNavigationItem = navigationItems.first, navigationItems.count == 1 {
            navigationItem.setLeftBarButton(
                makeNavigationItem(navigationItem: firstNavigationItem),
                animated: true
            )
        } else {
            navigationItem.setLeftBarButtonItems(
                navigationItems.map(makeNavigationItem),
                animated: true
            )
        }
    }

    private func makeNavigationItem(navigationItem: PageNavigationItem) -> UIBarButtonItem {
        switch navigationItem {
        case let .text(title, onAction):
            textBarButtonItemFactory.make(
                title: title,
                primaryAction: UIAction { _ in
                    onAction()
                }
            )
        case let .symbol(symbolName, onAction):
            symbolBarButtonItemFactory.make(
                symbolName: symbolName,
                primaryAction: .action(
                    UIAction { _ in
                        onAction()
                    }
                )
            )
        }
    }

    private func setUpViews() {
        view.backgroundColor = .systemGroupedBackground
        view.directionalLayoutMargins.bottom = 16
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(collectionView)
        view.addSubview(callToActionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: callToActionView.topAnchor),

            callToActionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            callToActionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            callToActionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionViewLayout.invalidateLayout()
        })
    }

    private func handleItems(_ items: [PageItem]) {
        self.items = items
        collectionView.reloadData()
    }
}

extension PageViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        .zero
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return switch items[safe: indexPath.row]?.content {
        case let .pageHeader(pageHeader):
            configurePageHeaderCell(
                pageHeader: pageHeader,
                indexPath: indexPath
            )
        case let .featureRow(featureRow):
            configureFeatureRowCell(
                featureRow: featureRow,
                indexPath: indexPath
            )
        case let .migrationNote(businessModel, _):
            configureCloudMigrationNoteCell(
                businessModel: businessModel,
                indexPath: indexPath
            )
        case let .note(note, infoText, _):
            configureNoteCell(
                note: note,
                infoText: infoText,
                indexPath: indexPath
            )
        case nil:
            UICollectionViewCell()
        }
    }

    private func configurePageHeaderCell(
        pageHeader: PageHeaderBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PageHeaderCell.reuseIdentifier,
            for: indexPath
        ) as? PageHeaderCell else {
            return UICollectionViewCell()
        }
        cell.configure(pageHeader: pageHeader)
        return cell
    }

    private func configureFeatureRowCell(
        featureRow: FeatureRowBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FeatureRowCell.reuseIdentifier,
            for: indexPath
        ) as? FeatureRowCell else {
            return UICollectionViewCell()
        }
        cell.configure(featureRow: featureRow)
        return cell
    }

    private func configureCloudMigrationNoteCell(
        businessModel: CloudMigrationNoteBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CloudMigrationNoteCell.reuseIdentifier,
            for: indexPath
        ) as? CloudMigrationNoteCell else {
            return UICollectionViewCell()
        }
        cell.configure(businessModel: businessModel)
        return cell
    }

    private func configureNoteCell(
        note: NoteBusinessModel,
        infoText: String?,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NoteCell.reuseIdentifier,
            for: indexPath
        ) as? NoteCell else {
            return UICollectionViewCell()
        }
        cell.configure(note: note, infoText: infoText)
        return cell
    }
}

extension PageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items[safe: indexPath.row] else { return }
        switch item.content {
        case let .migrationNote(_, onAction):
            onAction()
        case let .note(_, _, onAction):
            onAction()
        default:
            break
        }
    }
}

extension PageViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let item = items[safe: indexPath.row] else {
            return .zero
        }

        let margins = collectionView.layoutMargins
        let maxWidth = collectionView.bounds.width - margins.left - margins.right

        return switch item.sizing {
        case .fullWidth:
            makeFullWidthSize(
                content: item.content,
                maxWidth: maxWidth
            )
        case let .equalSplit(perRow, itemHeight):
            makeEqualSplitSize(
                perRow: perRow,
                itemHeight: itemHeight,
                maxWidth: maxWidth
            )
        case let .adaptiveGrid(maxColumns, itemHeight):
            makeAdaptiveGrid(
                maxColumns: maxColumns,
                itemHeight: itemHeight,
                maxWidth: maxWidth
            )
        }
    }

    private func makeFullWidthSize(
        content: PageItem.Content,
        maxWidth: CGFloat
    ) -> CGSize {
        let targetSize = CGSize(
            width: maxWidth,
            height: UIView.layoutFittingCompressedSize.height
        )

        switch content {
        case let .pageHeader(pageHeader):
            sizingHeaderCell.configure(pageHeader: pageHeader)
            return sizingHeaderCell.contentView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )

        case let .featureRow(featureRow):
            sizingFeatureRowCell.configure(featureRow: featureRow)
            return sizingFeatureRowCell.contentView.systemLayoutSizeFitting(
                targetSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )

        case .migrationNote, .note:
            return CGSize(width: maxWidth, height: 44)
        }
    }

    private func makeEqualSplitSize(
        perRow: Int,
        itemHeight: CGFloat,
        maxWidth: CGFloat
    ) -> CGSize {
        let totalSpacing = Constants.itemSpacing * CGFloat(perRow - 1)
        let width = (maxWidth - totalSpacing) / CGFloat(perRow)
        return CGSize(width: width, height: itemHeight)
    }

    private func makeAdaptiveGrid(
        maxColumns: Int,
        itemHeight: CGFloat,
        maxWidth: CGFloat
    ) -> CGSize {
        let isLandscape = collectionView.bounds.width > collectionView.bounds.height
        let columns = CGFloat(isLandscape ? maxColumns : 1)
        let totalSpacing = Constants.itemSpacing * (columns - 1)
        let width = (maxWidth - totalSpacing) / columns
        return CGSize(width: width, height: itemHeight)
    }
}
