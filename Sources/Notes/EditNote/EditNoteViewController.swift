import UIKit
import PencilKit

final class EditNoteViewController: UIViewController {

    private enum Constants {

        struct CanvasView {
            static let maximumZoomScale = CGFloat(3)
        }
    }

#if !targetEnvironment(macCatalyst)
    private lazy var toolPicker = PKToolPicker()
#endif

    private lazy var canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.drawingPolicy = .anyInput
        canvasView.maximumZoomScale = Constants.CanvasView.maximumZoomScale
        return canvasView
    }()

    private let viewModel: EditNoteViewModel
    private let toggleEditingBarButtonItemFactory: ToggleEditingBarButtonItemFactory
    private let expandMoreBarButtonItemFactory: BarButtonItemFactory

    init(
        viewModel: EditNoteViewModel,
        toggleEditingBarButtonItemFactory: ToggleEditingBarButtonItemFactory,
        expandMoreBarButtonItemFactory: BarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.toggleEditingBarButtonItemFactory = toggleEditingBarButtonItemFactory
        self.expandMoreBarButtonItemFactory = expandMoreBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    override func viewDidLoad() {
        setUpNavigationBar()
        setUpViews()

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

#if !targetEnvironment(macCatalyst)
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
#endif
    }

    private func setUpNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Project Brainstorming"

        let expandMoreBarButtonItem = expandMoreBarButtonItemFactory.make(
            primaryAction: UIAction { [weak self] _ in
                
            }
        )

#if targetEnvironment(macCatalyst)
        navigationItem.rightBarButtonItem = expandMoreBarButtonItem
#else
        navigationItem.rightBarButtonItems = [
            expandMoreBarButtonItem,
            toggleEditingBarButtonItemFactory.make(
                primaryAction: UIAction { [weak self] _ in
                    self?.viewModel.didTapToggleEditingButton()
                },
                isOn: true
            )
        ]
#endif
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(canvasView)

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
