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

    private var isEditingTask: Task<Void, Never>?

    private let viewModel: EditNoteViewModel
    private let toggleEditingBarButtonItemFactory: ToggleEditingBarButtonItemFactory
    private let expandMoreBarButtonItemFactory: ExpandMoreMenuBarButtonItemFactory

    init(
        viewModel: EditNoteViewModel,
        toggleEditingBarButtonItemFactory: ToggleEditingBarButtonItemFactory,
        expandMoreBarButtonItemFactory: ExpandMoreMenuBarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.toggleEditingBarButtonItemFactory = toggleEditingBarButtonItemFactory
        self.expandMoreBarButtonItemFactory = expandMoreBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)

        isEditingTask = Task { @MainActor in
            for await isEditing in viewModel.isEditing {
                handleEditing(isEditing: isEditing)
            }
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        assertionFailure("\(#function) has not been implemented")
        return nil
    }

    deinit {
        isEditingTask?.cancel()
    }

    override func viewDidLoad() {
        setUpNavigationBar()
        setUpViews()

        super.viewDidLoad()
    }

    private func setUpNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Project Brainstorming"
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground
        view.addSubview(canvasView)

#if !targetEnvironment(macCatalyst)
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
#endif

        NSLayoutConstraint.activate([
            canvasView.topAnchor.constraint(equalTo: view.topAnchor),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func handleEditing(isEditing: Bool?) {
        let rightNavigationBarButtonItems = makeRightNavigationBarButtonItems(isEditing: isEditing)

        if let isEditing, isEditing {
            canvasView.becomeFirstResponder()

            if #available(iOS 18.0, *) {
                canvasView.isDrawingEnabled = true
            } else {
                canvasView.isUserInteractionEnabled = true
            }
        } else {
            canvasView.resignFirstResponder()

            if #available(iOS 18.0, *) {
                canvasView.isDrawingEnabled = false
            } else {
                canvasView.isUserInteractionEnabled = false
            }
        }

        // There's a bug in the stack layouting of ``UINavigationItem`` which, if placing a single item,
        // causes this single item to stretch across the entire navigation bar.
        if let firstNavigationBarItem = rightNavigationBarButtonItems.first, rightNavigationBarButtonItems.count == 1 {
            navigationItem.setRightBarButton(firstNavigationBarItem, animated: false)
        } else {
            navigationItem.setRightBarButtonItems(rightNavigationBarButtonItems, animated: false)
        }
    }

    private func makeRightNavigationBarButtonItems(isEditing: Bool?) -> [UIBarButtonItem] {
        var barButtonItems = [UIBarButtonItem]()
        barButtonItems
            .append(
                expandMoreBarButtonItemFactory
                    .make(menu: UIMenu.make(noteMenuConfigurations: viewModel.menuConfigurations))
            )

        if let isEditing {
            barButtonItems.append(
                toggleEditingBarButtonItemFactory.make(
                    primaryAction: UIAction { [weak self] _ in
                        self?.viewModel.didTapToggleEditingButton(isEditing: isEditing)
                    },
                    isOn: isEditing
                )
            )
        }

        return barButtonItems
    }
}
