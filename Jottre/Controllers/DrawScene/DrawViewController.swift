//
//  DrawViewController.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import PencilKit
import os.log

class DrawViewController: UIViewController {
    
    // MARK: - Properties
    
    var node: Node!
    
    var hasModifiedDrawing: Bool = false
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    

    
    // MARK: - Subviews
    
    var canvasView: PKCanvasView = {
        let canvasView = PKCanvasView()
            canvasView.translatesAutoresizingMaskIntoConstraints = false
            canvasView.drawingPolicy = .pencilOnly
            canvasView.alwaysBounceVertical = true
            canvasView.maximumZoomScale = 3
        return canvasView
    }()
    
    var toolPicker: PKToolPicker!
    
    
    
    // MARK: - Init
    
    init(node: Node) {
        super.init(nibName: nil, bundle: nil)
        self.node = node
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupDelegates()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / node.nodeCodable!.width
        canvasView.minimumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        updateContentSizeForDrawing()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if hasModifiedDrawing {
            node.setDrawing(drawing: canvasView.drawing)
        }
        
        view.window?.windowScene?.screenshotService?.delegate = nil
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    
    
    // MARK: - Methods
    
    func setupViews() {
        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = node.name
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(exportDrawing))
        
        traitCollectionDidChange(traitCollection)
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(canvasView)
        canvasView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        canvasView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        canvasView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        updateContentSizeForDrawing()
        
        guard let parent = parent, let window = parent.view.window, let windowScene = window.windowScene, let screenshotService = windowScene.screenshotService else {
            Logger.main.debug("Could not find screenShotService")
            return
        }
        screenshotService.delegate = self
        
    }
    
    
    private func setupDelegates() {
        
        guard node != nil else { return }
        
        canvasView.delegate = self
        canvasView.drawing = node.nodeCodable!.drawing
        canvasView.contentInset = UIEdgeInsets(top: -75, left: 0, bottom: 0, right: 0)
        
        if !UIDevice.isLimited() {
            toolPicker = PKToolPicker()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)

            canvasView.becomeFirstResponder()
        }
        
    }
 
    
    func updateContentSizeForDrawing() {
        
        let drawing = canvasView.drawing
        let contentHeight: CGFloat

        if !drawing.bounds.isNull {
            contentHeight = max(canvasView.bounds.height, (drawing.bounds.maxY + 500) * canvasView.zoomScale)
        } else {
            contentHeight = canvasView.bounds.height
        }
        canvasView.contentSize = CGSize(width: node.nodeCodable!.width * canvasView.zoomScale, height: contentHeight)
        
    }
    
    
    @objc func exportDrawing() {
        
        let alertController = UIAlertController(title: "Export note", message: "", preferredStyle: .actionSheet)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        alertController.addAction(createExportToPDFAction())
        alertController.addAction(createExportToJPGAction())
        alertController.addAction(createExportToPNGAction())
        alertController.addAction(createShareAction())
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
        present(alertController, animated: true, completion: nil)
        
    }
    
}
