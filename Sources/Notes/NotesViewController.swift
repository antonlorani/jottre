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
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.reuseIdentifier)
        return collectionView
    }()

    private var itemsTask: Task<Void, Never>?
    private var items = [NotesViewModel.Item]()

    private let viewModel: NotesViewModel
    private let settingsBarButtonItemFactory: BarButtonItemFactory
    private let createNoteBarButtonItemFactory: BarButtonItemFactory

    init(
        viewModel: NotesViewModel,
        settingsBarButtonItemFactory: BarButtonItemFactory,
        createNoteBarButtonItemFactory: BarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.settingsBarButtonItemFactory = settingsBarButtonItemFactory
        self.createNoteBarButtonItemFactory = createNoteBarButtonItemFactory
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
        
        navigationItem.leftBarButtonItem = settingsBarButtonItemFactory.make(
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapSettingsButton()
            }
        )
        navigationItem.rightBarButtonItem = createNoteBarButtonItemFactory.make(
            primaryAction: UIAction { [weak self] _ in
                self?.viewModel.didTapCreateNoteButton()
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
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

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

        return makeNoteCell(
            note: item.note,
            indexPath: indexPath
        )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = Constants.CollectionViewFlowLayout.spacing
        let available = collectionView.bounds.width - Constants.CollectionViewFlowLayout.inset * 2
        let columns = max(1, floor((available + spacing) / (Constants.CollectionViewFlowLayout.minimumCellWidth + spacing)))
        let width = (available - spacing * (columns - 1)) / columns
        return CGSize(
            width: width,
            height: width * 1.1
        )
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
        cell.configure(note: note)
        return cell
    }
}
