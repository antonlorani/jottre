import UIKit

final class SettingsViewController: UIViewController {

    private enum Constants {

        enum CollectionViewFlowLayout {
            static let inset = CGFloat(16)
            static let spacing = CGFloat(8)
            static let itemHeight = CGFloat(56)
        }
    }

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = Constants.CollectionViewFlowLayout.spacing
        flowLayout.minimumLineSpacing = Constants.CollectionViewFlowLayout.spacing
        flowLayout.sectionInset = UIEdgeInsets(
            top: Constants.CollectionViewFlowLayout.inset,
            left: 0,
            bottom: Constants.CollectionViewFlowLayout.inset,
            right: 0
        )
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
        collectionView.register(
            SettingsDropdownCell.self,
            forCellWithReuseIdentifier: SettingsDropdownCell.reuseIdentifier
        )
        collectionView.register(
            SettingsToggleCell.self,
            forCellWithReuseIdentifier: SettingsToggleCell.reuseIdentifier
        )
        collectionView.register(
            SettingsExternalLinkCell.self,
            forCellWithReuseIdentifier: SettingsExternalLinkCell.reuseIdentifier
        )
        collectionView.register(
            SettingsInfoCell.self,
            forCellWithReuseIdentifier: SettingsInfoCell.reuseIdentifier
        )
        return collectionView
    }()

    private var itemsTask: Task<Void, Never>?
    private var items = [SettingsViewModel.Item]()

    private let viewModel: SettingsViewModel
    private let symbolBarButtonItemFactory: SymbolBarButtonItemFactory

    init(
        viewModel: SettingsViewModel,
        symbolBarButtonItemFactory: SymbolBarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.symbolBarButtonItemFactory = symbolBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)

        itemsTask = Task { [weak self] in
            for await items in viewModel.items {
                self?.items = items
                self?.collectionView.reloadData()
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    deinit {
        itemsTask?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationItem()
        setUpViews()
    }

    private func setUpNavigationItem() {
        navigationItem.title = "Settings"

        navigationItem.rightBarButtonItem = symbolBarButtonItemFactory.make(
            symbolName: "xmark",
            primaryAction: .action(
                UIAction { [weak self] _ in
                    self?.viewModel.didTapCloseButton()
                }
            )
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

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
        ])
    }
}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch items[safe: indexPath.row] {
        case let .dropdown(businessModel):
            makeSettingsDropdownCell(
                businessModel: businessModel,
                indexPath: indexPath
            )
        case let .toggle(businessModel):
            makeSettingsToggleCell(
                businessModel: businessModel,
                indexPath: indexPath
            )
        case let .externalLink(businessModel, _):
            makeSettingsExternalLinkCell(
                businessModel: businessModel,
                indexPath: indexPath
            )
        case let .text(businessModel):
            makeSettingsInfoCell(
                businessModel: businessModel,
                indexPath: indexPath
            )
        case nil:
            UICollectionViewCell()
        }
    }

    private func makeSettingsDropdownCell(
        businessModel: SettingsDropdownBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsDropdownCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsDropdownCell else {
            return UICollectionViewCell()
        }
        cell.configure(businessModel: businessModel)
        return cell
    }

    private func makeSettingsToggleCell(
        businessModel: SettingsToggleBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsToggleCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsToggleCell else {
            return UICollectionViewCell()
        }
        cell.configure(businessModel: businessModel)
        return cell
    }

    private func makeSettingsExternalLinkCell(
        businessModel: SettingsExternalLinkBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsExternalLinkCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsExternalLinkCell else {
            return UICollectionViewCell()
        }
        cell.configure(businessModel: businessModel)
        return cell
    }

    private func makeSettingsInfoCell(
        businessModel: SettingsInfoBusinessModel,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsInfoCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsInfoCell else {
            return UICollectionViewCell()
        }
        cell.configure(businessModel: businessModel)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        return CGSize(
            width: width,
            height: Constants.CollectionViewFlowLayout.itemHeight
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch items[safe: indexPath.row] {
        case let .externalLink(_, onAction):
            onAction()
        default:
            break
        }
    }
}
