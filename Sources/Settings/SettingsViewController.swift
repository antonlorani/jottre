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
            left: Constants.CollectionViewFlowLayout.inset,
            bottom: Constants.CollectionViewFlowLayout.inset,
            right: Constants.CollectionViewFlowLayout.inset
        )
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
    private let closeBarButtonItemFactory: BarButtonItemFactory

    init(
        viewModel: SettingsViewModel,
        closeBarButtonItemFactory: BarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.closeBarButtonItemFactory = closeBarButtonItemFactory
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

        navigationItem.leftBarButtonItem = closeBarButtonItemFactory.make(
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapCloseButton()
            }
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemGroupedBackground

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
        let inset = Constants.CollectionViewFlowLayout.inset
        let width = collectionView.bounds.width - inset * 2
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
