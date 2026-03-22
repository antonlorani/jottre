import UIKit

final class CloudMigrationViewController: UIViewController {

    private enum Constants {
        enum CollectionViewFlowLayout {
            static let inset = CGFloat(16)
            static let spacing = CGFloat(8)
            static let itemHeight = CGFloat(68)
        }
    }

    private lazy var pageHeaderView: PageHeaderView = {
        let view = PageHeaderView(configuration: viewModel.pageHeaderConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

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
        collectionView.register(
            CloudMigrationNoteCell.self,
            forCellWithReuseIdentifier: CloudMigrationNoteCell.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var callToActionView: PageCallToActionView = {
        let view = PageCallToActionView(actions: viewModel.actions)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var itemsTask: Task<Void, Never>?
    private var items = [CloudMigrationViewModel.Item]()

    private let viewModel: CloudMigrationViewModel

    init(viewModel: CloudMigrationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        itemsTask = Task { [weak self] in
            for await items in viewModel.items {
                self?.handleItems(items: items)
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

        setUpViews()
    }

    private func setUpViews() {
        view.backgroundColor = .systemGroupedBackground
        view.directionalLayoutMargins.bottom = 16

        view.addSubview(pageHeaderView)
        view.addSubview(collectionView)
        view.addSubview(callToActionView)

        NSLayoutConstraint.activate([
            pageHeaderView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: 8),
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

    private func handleItems(items: [CloudMigrationViewModel.Item]) {
        self.items = items
        collectionView.reloadData()
    }
}

extension CloudMigrationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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

        return makeCloudMigrationNoteCell(
            businessModel: item.businessModel,
            indexPath: indexPath
        )
    }

    private func makeCloudMigrationNoteCell(
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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let spacing = Constants.CollectionViewFlowLayout.spacing
        let available = collectionView.bounds.width - collectionView.layoutMargins.left - collectionView.layoutMargins.right
        let columns: CGFloat = collectionView.bounds.width > collectionView.bounds.height ? 2 : 1
        let width = (available - spacing * (columns - 1)) / columns
        return CGSize(
            width: width,
            height: Constants.CollectionViewFlowLayout.itemHeight
        )
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = items[safe: indexPath.row] else {
            return
        }
        item.onAction()
    }
}
