import UIKit

final class PageViewController: UIViewController {

    private enum Constants {
        static let itemSpacing = CGFloat(8)
    }

    private lazy var collectionViewLayout: UICollectionViewCompositionalLayout = {
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        return UICollectionViewCompositionalLayout(
            sectionProvider: { [weak self] _, environment in
                guard let self else {
                    return self?.makeDefaultLayoutSection()
                }
                return makeLayoutSection(
                    items: self.dataSource.snapshot().itemIdentifiers,
                    contentWidth: environment.container.effectiveContentSize.width
                )
            },
            configuration: configuration
        )
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Int, PageCellItem> = {
        UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            self?.registerIfNeeded(item.cellType)

            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: item.cellType.reuseIdentifier,
                for: indexPath
            )
            item.configure(cell)
            return cell
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.preservesSuperviewLayoutMargins = true
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var callToActionView: PageCallToActionView = {
        let view = PageCallToActionView(actions: viewModel.actions)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var registeredReuseIdentifiers = Set<String>()

    private var leftNavigationItemsTask: Task<Void, Never>?
    private var rightNavigationItemsTask: Task<Void, Never>?
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
        leftNavigationItemsTask?.cancel()
        rightNavigationItemsTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
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

    private func registerIfNeeded(_ cellType: any PageCell.Type) {
        let identifier = cellType.reuseIdentifier
        guard !registeredReuseIdentifiers.contains(identifier) else {
            return
        }
        collectionView.register(cellType, forCellWithReuseIdentifier: identifier)
        registeredReuseIdentifiers.insert(identifier)
    }

    private func handleItems(_ items: [PageCellItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, PageCellItem>()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
        collectionViewLayout.invalidateLayout()
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

    private func makeDefaultLayoutSection() -> NSCollectionLayoutSection {
        let (group, _) = makeFullWidthRowLayoutGroup(estimatedHeight: 120)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsetsReference = .layoutMargins
        return section
    }

    private func makeLayoutSection(
        items: [PageCellItem],
        contentWidth: CGFloat
    ) -> NSCollectionLayoutSection {
        let rowGroups = makeRowLayoutGroups(
            items: items,
            contentWidth: contentWidth
        )
        guard !rowGroups.isEmpty else {
            return makeDefaultLayoutSection()
        }

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(1000)
            ),
            subitems: rowGroups
        )
        group.interItemSpacing = .fixed(Constants.itemSpacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsetsReference = .layoutMargins
        return section
    }

    private func makeRowLayoutGroups(
        items: [PageCellItem],
        contentWidth: CGFloat
    ) -> [NSCollectionLayoutGroup] {
        var groups: [NSCollectionLayoutGroup] = []
        var i = 0
        while i < items.count {
            let (group, consumed) = makeRowLayoutGroup(
                sizing: items[i].sizing,
                contentWidth: contentWidth
            )
            groups.append(group)
            i += min(consumed, items.count - i)
        }
        return groups
    }

    private func makeRowLayoutGroup(
        sizing: PageCellSizingStrategy,
        contentWidth: CGFloat
    ) -> (NSCollectionLayoutGroup, Int) {
        switch sizing {
        case let .fullWidth(estimatedHeight):
            return makeFullWidthRowLayoutGroup(
                estimatedHeight: estimatedHeight
            )
        case let .equalSplit(perRow, height):
            return makeEqualSplitRowLayoutGroup(
                perRow: perRow,
                height: height
            )
        case let .adaptiveGrid(maxColumns, height):
            return makeAdaptiveGridRowLayoutGroup(
                maxColumns: maxColumns,
                height: height,
                contentWidth: contentWidth
            )
        }
    }

    private func makeFullWidthRowLayoutGroup(
        estimatedHeight: CGFloat
    ) -> (NSCollectionLayoutGroup, Int) {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(estimatedHeight)
            ),
            subitems: [item]
        )
        return (group, 1)
    }

    private func makeEqualSplitRowLayoutGroup(
        perRow: Int,
        height: CGFloat
    ) -> (NSCollectionLayoutGroup, Int) {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0 / CGFloat(perRow)),
                heightDimension: .absolute(height)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(height)
            ),
            subitem: item,
            count: perRow
        )
        group.interItemSpacing = .fixed(Constants.itemSpacing)
        return (group, perRow)
    }

    private func makeAdaptiveGridRowLayoutGroup(
        maxColumns: Int,
        height: CGFloat,
        contentWidth: CGFloat
    ) -> (NSCollectionLayoutGroup, Int) {
        let minCellWidth: CGFloat = 160
        let columns = min(maxColumns, max(1, Int(contentWidth / minCellWidth)))
        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .absolute(height)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(height)
            ),
            subitem: item,
            count: columns
        )
        group.interItemSpacing = .fixed(Constants.itemSpacing)
        return (group, columns)
    }
}

extension PageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.itemIdentifier(for: indexPath)?.handleAction(.tap)
    }
}
