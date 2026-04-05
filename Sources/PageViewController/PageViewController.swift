/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import UIKit

final class PageViewController: UIViewController {

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
        collectionView.contentInset.bottom = DesignTokens.Spacing.md
        collectionView.delegate = self
        return collectionView
    }()

    private lazy var callToActionView: PageCallToActionView = {
        let view = PageCallToActionView(actions: viewModel.actions)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var withCallToActionViewConstraints = [
        collectionView.bottomAnchor.constraint(equalTo: callToActionView.topAnchor),

        callToActionView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
        callToActionView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        callToActionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
    ]

    private lazy var withoutCallToActionViewConstraints = [
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

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

        setUpViews()
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

    private func setUpViews() {
        navigationItem.title = viewModel.title
        view.backgroundColor = .systemGroupedBackground
        view.directionalLayoutMargins.bottom = DesignTokens.Spacing.md
        navigationItem.largeTitleDisplayMode = .never

        view.addSubview(collectionView)

        var constraints = [
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ]

        if viewModel.actions.isEmpty {
            constraints.append(contentsOf: withoutCallToActionViewConstraints)
        } else {
            view.addSubview(callToActionView)
            constraints.append(contentsOf: withCallToActionViewConstraints)
        }

        NSLayoutConstraint.activate(constraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didLoad()
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
        group.interItemSpacing = .fixed(items.first?.sizing.rowSpacing ?? DesignTokens.Spacing.md)

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
        case let .fullWidth(estimatedHeight, _):
            makeFullWidthRowLayoutGroup(
                estimatedHeight: estimatedHeight
            )
        case let .equalSplit(perRow, height, columnSpacing, _):
            makeEqualSplitRowLayoutGroup(
                perRow: perRow,
                height: height,
                columnSpacing: columnSpacing
            )
        case let .adaptiveGrid(minColumns, maxColumns, minItemWidth, maxItemWidth, columnSpacing, _, aspectRatio):
            makeAdaptiveGridRowLayoutGroup(
                minColumns: minColumns,
                maxColumns: maxColumns,
                minItemWidth: minItemWidth,
                maxItemWidth: maxItemWidth,
                columnSpacing: columnSpacing,
                aspectRatio: aspectRatio,
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
        height: CGFloat,
        columnSpacing: CGFloat
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
        group.interItemSpacing = .fixed(columnSpacing)
        return (group, perRow)
    }

    private func makeAdaptiveGridRowLayoutGroup(
        minColumns: Int,
        maxColumns: Int,
        minItemWidth: CGFloat,
        maxItemWidth: CGFloat,
        columnSpacing: CGFloat,
        aspectRatio: CGSize,
        contentWidth: CGFloat
    ) -> (NSCollectionLayoutGroup, Int) {
        let columnsNeeded = Int(ceil((contentWidth + columnSpacing) / (maxItemWidth + columnSpacing)))
        let columnsAllowed = Int((contentWidth + columnSpacing) / (minItemWidth + columnSpacing))
        let columns = max(minColumns, min(maxColumns, min(columnsAllowed, max(columnsNeeded, minColumns))))
        let itemWidth = (contentWidth - columnSpacing * CGFloat(columns - 1)) / CGFloat(columns)
        let itemHeight = itemWidth * aspectRatio.height / aspectRatio.width

        let item = NSCollectionLayoutItem(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .absolute(itemHeight)
            )
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemHeight)
            ),
            subitem: item,
            count: columns
        )
        group.interItemSpacing = .fixed(columnSpacing)
        return (group, columns)
    }
}

extension PageViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource.itemIdentifier(for: indexPath)?.handleAction(.tap)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        dataSource.itemIdentifier(for: indexPath)?.contextMenuConfiguration()
    }
}
