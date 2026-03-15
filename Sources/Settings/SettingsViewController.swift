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
            SettingsTextCell.self,
            forCellWithReuseIdentifier: SettingsTextCell.reuseIdentifier
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
        guard let item = items[safe: indexPath.row] else {
            return UICollectionViewCell()
        }
        return switch item.content {
        case let .dropdown(value, options):
            makeSettingsDropdownCell(
                name: item.name,
                value: value,
                options: options,
                indexPath: indexPath
            )
        case let .toggle(isOn):
            makeSettingsToggleCell(
                name: item.name,
                isOn: isOn,
                indexPath: indexPath
            )
        case .externalLink:
            makeSettingsExternalLinkCell(
                name: item.name,
                indexPath: indexPath
            )
        case let .text(value):
            makeSettingsTextCell(
                name: item.name,
                value: value,
                indexPath: indexPath
            )
        }
    }

    private func makeSettingsDropdownCell(
        name: String,
        value: String,
        options: [String],
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsDropdownCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsDropdownCell else {
            return UICollectionViewCell()
        }
        cell.configure(name: name, value: value, options: options) { [weak self] selected in
            self?.items[indexPath.row] = .init(
                name: name,
                content: .dropdown(value: selected, options: options)
            )
            self?.collectionView.reloadItems(at: [indexPath])
        }
        return cell
    }

    private func makeSettingsToggleCell(
        name: String,
        isOn: Bool,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsToggleCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsToggleCell else {
            return UICollectionViewCell()
        }
        cell.configure(name: name, isOn: isOn)
        return cell
    }

    private func makeSettingsExternalLinkCell(
        name: String,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsExternalLinkCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsExternalLinkCell else {
            return UICollectionViewCell()
        }
        cell.configure(name: name)
        return cell
    }

    private func makeSettingsTextCell(
        name: String,
        value: String,
        indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SettingsTextCell.reuseIdentifier,
            for: indexPath
        ) as? SettingsTextCell else {
            return UICollectionViewCell()
        }
        cell.configure(name: name, value: value)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let inset = Constants.CollectionViewFlowLayout.inset
        let width = collectionView.bounds.width - inset * 2
        return CGSize(width: width, height: Constants.CollectionViewFlowLayout.itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items[safe: indexPath.row] else {
            return
        }
        if case let .externalLink(onAction) = item.content {
            onAction()
        }
    }
}
