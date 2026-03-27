/*
 Jottre: Minimalistic jotting for iPhone, iPad and Mac.
 Copyright (C) 2021-2026 Anton Lorani

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

@preconcurrency import PencilKit
import UIKit

final class EditJotViewController: UIViewController {

    private enum Constants {

        enum CanvasView {
            static let maximumZoomScale = CGFloat(3)
            static let bottomFreespace = CGFloat(500)
        }
    }

    #if !targetEnvironment(macCatalyst)
    private lazy var toolPicker = PKToolPicker()
    #endif

    private lazy var canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
        canvasView.delegate = self
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.drawingPolicy = .anyInput
        canvasView.maximumZoomScale = Constants.CanvasView.maximumZoomScale
        canvasView.bounces = false
        return canvasView
    }()

    private var drawingWidth = CGFloat.zero

    private var isEditingTask: Task<Void, Never>?
    private var drawingTask: Task<Void, Never>?

    private let viewModel: EditJotViewModel
    private let symbolBarButtonItemFactory: SymbolBarButtonItemFactory

    init(
        viewModel: EditJotViewModel,
        symbolBarButtonItemFactory: SymbolBarButtonItemFactory
    ) {
        self.viewModel = viewModel
        self.symbolBarButtonItemFactory = symbolBarButtonItemFactory
        super.init(nibName: nil, bundle: nil)

        isEditingTask = Task { @MainActor in
            for await isEditing in viewModel.isEditing {
                handleEditing(isEditing: isEditing)
            }
        }
        drawingTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            for await drawing in viewModel.drawing {
                drawingWidth = drawing.width
                canvasView.drawing = drawing.value

                if canvasView.superview == nil {
                    setUpCanvasView()
                }
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

        viewModel.didLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let scale = canvasView.bounds.width / drawingWidth
        canvasView.minimumZoomScale = scale
        canvasView.zoomScale = scale

        let drawingMaxY =
            if canvasView.drawing.bounds.isNull {
                CGFloat.zero
            } else {
                canvasView.drawing.bounds.maxY + Constants.CanvasView.bottomFreespace
            }

        canvasView.contentSize = CGSize(
            width: canvasView.bounds.width,
            height: max(canvasView.bounds.height, drawingMaxY * scale)
        )
        canvasView.contentOffset = CGPoint(
            x: 0,
            y: -canvasView.adjustedContentInset.top
        )
    }

    private func setUpNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.title

        navigationItem.leftBarButtonItem = symbolBarButtonItemFactory.make(
            symbolName: "chevron.left",
            primaryAction: .action(
                UIAction { [weak self] _ in
                    self?.viewModel.didTapBackButton()
                }
            )
        )
    }

    private func setUpViews() {
        view.backgroundColor = .systemBackground

        #if !targetEnvironment(macCatalyst)
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        #endif
    }

    private func setUpCanvasView() {
        view.addSubview(canvasView)
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
                symbolBarButtonItemFactory
                    .make(
                        symbolName: "ellipsis",
                        primaryAction: .menu(
                            .make(
                                jotMenuConfigurations: viewModel.menuConfigurations
                            )
                        )
                    )
            )

        if let isEditing {
            barButtonItems.append(
                symbolBarButtonItemFactory
                    .make(
                        symbolName: isEditing ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle",
                        primaryAction: .action(
                            UIAction { [weak self] _ in
                                self?.viewModel.didTapToggleEditingButton(isEditing: isEditing)
                            }
                        )
                    )
            )
        }

        return barButtonItems
    }
}

extension EditJotViewController: PKCanvasViewDelegate {

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print("Drawing did change")
        viewModel.didChangeDrawing(canvasView.drawing)
    }
}
