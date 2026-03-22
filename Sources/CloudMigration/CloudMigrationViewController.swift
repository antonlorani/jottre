import UIKit

final class CloudMigrationViewController: UIViewController {

    private enum Constants {
        enum Headline {
            static let font = {
                let font = UIFont.preferredFont(forTextStyle: .largeTitle)
                return UIFont.boldSystemFont(ofSize: font.pointSize)
            }()
        }

        enum Subheadline {
            static let font = {
                let font = UIFont.preferredFont(forTextStyle: .subheadline)
                return UIFont.boldSystemFont(ofSize: font.pointSize)
            }()
        }

        enum CollectionViewFlowLayout {
            static let inset = CGFloat(16)
            static let spacing = CGFloat(8)
            static let itemHeight = CGFloat(68)
        }
    }

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "iCloud is ready"
        label.font = Constants.Headline.font
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subheadlineLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Your Jots can now sync across all your devices. Choose which ones to bring along."
        label.font = Constants.Subheadline.font
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = Constants.CollectionViewFlowLayout.spacing
        flowLayout.minimumLineSpacing = Constants.CollectionViewFlowLayout.spacing
        flowLayout.sectionInset = UIEdgeInsets(
            top: 0,
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
        collectionView.register(
            CloudMigrationNoteCell.self,
            forCellWithReuseIdentifier: CloudMigrationNoteCell.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var doneButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Done"
        configuration.baseBackgroundColor = .label
        configuration.baseForegroundColor = .systemBackground
        configuration.cornerStyle = .capsule
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        let button = UIButton(
            configuration: configuration,
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapDoneButton()
            }
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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

        view.addSubview(headlineLabel)
        view.addSubview(subheadlineLabel)
        view.addSubview(collectionView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 42),
            headlineLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headlineLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            subheadlineLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 8),
            subheadlineLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            subheadlineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).withPriority(.defaultHigh),
            subheadlineLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            subheadlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),

            collectionView.topAnchor.constraint(equalTo: subheadlineLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: doneButton.topAnchor),

            doneButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 59),
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
