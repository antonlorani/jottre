import UIKit
import Combine

final class RootViewController: UIViewController {

    private struct Constants {
        struct InfoContainerView {
            static let width = CGFloat(300)
        }

        struct CollectionView {
            static let spacing = CGFloat(20)
            static let sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
            static let minWidth = CGFloat(232)
            static let height = CGFloat(291)
        }

        struct BackgroundLoadingView {
            static let paddingBottom = CGFloat(5)
        }
    }

    private let backgroundLoadingViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let infoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.sectionInset = Constants.CollectionView.sectionInset
        collectionViewLayout.minimumLineSpacing = Constants.CollectionView.spacing
        collectionViewLayout.minimumInteritemSpacing = Constants.CollectionView.spacing

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.register(NoteCell.self, forCellWithReuseIdentifier: NoteCell.reuseIdentifier)
        return collectionView
    }()

    private var cancellables = Set<AnyCancellable>()
    private var items = [RootViewModel.Item]()
    private let viewModel: RootViewModel

    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setUpViews()
        setUpNavigationItem(
            title: viewModel.getNavigationTitle(),
            addNoteButtonTitle: viewModel.getAddNoteButtonTitle()
        )
        setUpConstraints()
        setUpDelegates()
        bindViewModel()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        collectionView.collectionViewLayout.invalidateLayout()
    }

    private func setUpNavigationItem(
        title: String,
        addNoteButtonTitle: String?
    ) {
        navigationItem.title = title
        navigationItem.largeTitleDisplayMode = .automatic

        if let addNoteButtonTitle = addNoteButtonTitle {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                customView: NavigationTextButton(title: addNoteButtonTitle, target: self, action: #selector(addNoteButtonDidTap(_:)))
            )
        }

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            customView: SettingsButton(
                target: self,
                action: #selector(openPreferencesButtonDidTap(_:))
            )
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        view.addSubview(infoContainerView)
        view.addSubview(backgroundLoadingViewContainer)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        NSLayoutConstraint.activate([
            infoContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            backgroundLoadingViewContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundLoadingViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.BackgroundLoadingView.paddingBottom)
        ])
    }

    private func setUpDelegates() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func bindViewModel() {
        viewModel
            .items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.items = items
                self?.collectionView.performBatchUpdates {
                    self?.collectionView.reloadSections(IndexSet(integer: .zero))
                }
            }
            .store(in: &cancellables)

        viewModel
            .info
            .receive(on: DispatchQueue.main)
            .sink { [weak self] info in
                self?.updateInfo(info: info)
            }
            .store(in: &cancellables)

        viewModel
            .remoteFilesCountText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] remoteFilesText in
                self?.backgroundLoadingViewContainer.subviews.forEach { $0.removeFromSuperview() }
                if let remoteFilesText = remoteFilesText {
                    self?.setUpBackgroundLoading(text: remoteFilesText)
                }
            }
            .store(in: &cancellables)
    }

    @objc private func addNoteButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.addNoteButtonDidTap()
    }

    @objc private func openPreferencesButtonDidTap(_ sender: UIBarButtonItem) {
        viewModel.openPreferencesButtonDidTap()
    }

    private func updateInfo(info: RootViewModel.Info?) {
        infoContainerView.subviews.forEach { $0.removeFromSuperview() }
        collectionView.isHidden = true
        switch info {
        case let .largeText(text):
            setUpLargeText(text: text)
        case let .loading(title):
            setUpLoading(title: title)
        case .none:
            collectionView.isHidden = false
        }
    }

    private func setUpLargeText(text: String) {
        let infoTextView = InfoTextView(text: text)
        infoTextView.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.addSubview(infoTextView)
        NSLayoutConstraint.activate([
            infoTextView.topAnchor.constraint(equalTo: infoContainerView.topAnchor),
            infoTextView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            infoTextView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            infoTextView.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor)
        ])
    }

    private func setUpLoading(title: String) {
        let loadingView = LoadingView(title: title, tintColor: .systemGray2)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: infoContainerView.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor)
        ])
    }

    private func setUpBackgroundLoading(text: String) {
        let backgroundLoadingView = BackgroundLoadingView(title: text)
        backgroundLoadingView.translatesAutoresizingMaskIntoConstraints = false
        backgroundLoadingViewContainer.addSubview(backgroundLoadingView)
        NSLayoutConstraint.activate([
            backgroundLoadingView.topAnchor.constraint(equalTo: backgroundLoadingViewContainer.topAnchor),
            backgroundLoadingView.leadingAnchor.constraint(equalTo: backgroundLoadingViewContainer.leadingAnchor),
            backgroundLoadingView.trailingAnchor.constraint(equalTo: backgroundLoadingViewContainer.trailingAnchor),
            backgroundLoadingView.bottomAnchor.constraint(equalTo: backgroundLoadingViewContainer.bottomAnchor)
        ])
    }
}

extension RootViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        items[indexPath.row].onSelect()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]

        return makeNoteCell(
            indexPath: indexPath,
            title: item.title,
            image: item.image
        )
    }

    private func makeNoteCell(indexPath: IndexPath, title: String, image: UIImage) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoteCell.reuseIdentifier, for: indexPath) as? NoteCell else {
            return .init()
        }
        cell.configure(title: title, image: image)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        makeCellSize()
    }

    private func makeCellSize() -> CGSize {
        let minWidth = Constants.CollectionView.minWidth
        let widthWithSpacing = CGFloat(collectionView.frame.width - Constants.CollectionView.spacing * 2)
        let numberOfColumns = Int(widthWithSpacing / minWidth)
        let spacing = widthWithSpacing.truncatingRemainder(dividingBy: minWidth)

        let width: CGFloat
        if numberOfColumns == 1 {
            width = widthWithSpacing
        } else {
            let spacings = CGFloat(15 * numberOfColumns)
            width = minWidth + (spacing - spacings) / CGFloat(numberOfColumns)
        }

        return CGSize(width: width, height: Constants.CollectionView.height)
    }
}
