import UIKit
import Combine
import PencilKit

final class NoteViewController: UIViewController {

    private struct Constants {
        struct ExportNoteBarButton {
            static let systemName = "square.and.arrow.up"
        }
        struct CanvasView {
            static let maximumZoomScale = CGFloat(3)
        }
    }

    private let canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.drawingPolicy = .default
        canvasView.maximumZoomScale = Constants.CanvasView.maximumZoomScale
        return canvasView
    }()

    private let toolPicker = PKToolPicker()

    private var cancellables = Set<AnyCancellable>()
    private let viewModel: NoteViewModel

    init(viewModel: NoteViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        setUpNavigationBar()
        setUpViews()
        setUpConstraints()
        bindViewModel(viewModel: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateCanvas()
    }

    private func bindViewModel(viewModel: NoteViewModel) {
        viewModel
            .navigationTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] navigationTitle in
                self?.navigationItem.title = navigationTitle
            }
            .store(in: &cancellables)

        viewModel
            .drawing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] drawing in
                self?.canvasView.drawing = drawing
                self?.updateCanvas()
            }
            .store(in: &cancellables)
    }

    private func setUpNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.ExportNoteBarButton.systemName),
            style: .plain,
            target: self,
            action: #selector(didClickExportNote(_:))
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(canvasView)
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateCanvas() {
        let scale = canvasView.bounds.width / 1200
        canvasView.minimumZoomScale = scale
        canvasView.zoomScale = scale

        let contentHeight: CGFloat
        if canvasView.drawing.bounds.isNull {
            contentHeight = canvasView.bounds.height
        } else {
            contentHeight = max(canvasView.bounds.height, (canvasView.drawing.bounds.maxY + 500) * scale)
        }

        canvasView.contentSize = CGSize(
            width: 1200 * scale,
            height: contentHeight
        )
        canvasView.contentOffset = CGPoint(x: .zero, y: -canvasView.adjustedContentInset.top)
    }

    @objc private func didClickExportNote(_ sender: UIBarButtonItem) {
        viewModel.didClickExportNote()
    }
}
