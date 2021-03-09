//
//  DrawExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import PencilKit

extension DrawViewController {

    func reloadNavigationItems() {
        
        navigationItem.hidesBackButton = hasModifiedDrawing
        
        if hasModifiedDrawing {
            
            navigationItem.setLeftBarButton(UIBarButtonItem(customView: NavigationTextButton(title: NSLocalizedString("Save", comment: "Save the document"), target: self, action: #selector(self.writeDrawingHandler))), animated: true)
            
        } else {
            
            navigationItem.leftBarButtonItem = nil
            
            if isUndoEnabled {
            
                let spaceButton = UIBarButtonItem(customView: SpaceButtonBarItem())
                undoButton = UIBarButtonItem(customView: UndoButton(target: self, action: #selector(undoHandler)))
                redoButton = UIBarButtonItem(customView: RedoButton(target: self, action: #selector(redoHandler)))
                
                navigationItem.leftItemsSupplementBackButton = true
                navigationItem.setLeftBarButtonItems([spaceButton, undoButton, redoButton], animated: true)
            
                guard let undoManager = canvasView.undoManager else {
                    return
                }
                
                undoButton.isEnabled = undoManager.canUndo
                redoButton.isEnabled = undoManager.canRedo
                
            } else {
                
                navigationItem.setLeftBarButtonItems(nil, animated: true)
            
            }
            
        }
        
    }
    
    
    @objc func undoHandler() {
        canvasView.undoManager?.undo()
        reloadNavigationItems()
    }
    
    
    @objc func redoHandler() {
        canvasView.undoManager?.redo()
        reloadNavigationItems()
    }
    
}


extension DrawViewController: PKCanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        
        updateContentSizeForDrawing()
        reloadNavigationItems()
        
        if modifiedCount == 1 {
            hasModifiedDrawing = true
        } else {
            modifiedCount += 1
        }
    
    }
    
}


extension DrawViewController: UIScreenshotServiceDelegate {
    
    func startLoading() {
        toolPicker.setVisible(false, forFirstResponder: canvasView)
        canvasView.isUserInteractionEnabled = false
        loadingView.isAnimating = true
    }
    
    func stopLoading() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.isUserInteractionEnabled = true
        loadingView.isAnimating = false
    }
    
    func drawingToPDF(_ completion: @escaping (_ PDFData: Data?, _ indexOfCurrentPage: Int, _ rectInCurrentPage: CGRect) -> Void) {
        
        let drawing = canvasView.drawing
            
        let visibleRect = canvasView.bounds
                
        let pdfWidth: CGFloat = node.codable!.width
        let pdfHeight = drawing.bounds.maxY + 100
        let canvasContentSize = canvasView.contentSize.height
                
        let xOffsetInPDF = pdfWidth - (pdfWidth * visibleRect.minX / canvasView.contentSize.width)
        let yOffsetInPDF = pdfHeight - (pdfHeight * visibleRect.maxY / canvasContentSize)
        let rectWidthInPDF = pdfWidth * visibleRect.width / canvasView.contentSize.width
        let rectHeightInPDF = pdfHeight * visibleRect.height / canvasContentSize
            
        let visibleRectInPDF = CGRect(x: xOffsetInPDF, y: yOffsetInPDF, width: rectWidthInPDF, height: rectHeightInPDF)
            
        DispatchQueue.global(qos: .background).async {
                    
            let bounds = CGRect(x: 0, y: 0, width: pdfWidth, height: pdfHeight)
            let mutableData = NSMutableData()
                    
            UIGraphicsBeginPDFContextToData(mutableData, bounds, nil)
            UIGraphicsBeginPDFPage()
                    
            var yOrigin: CGFloat = 0
            let imageHeight: CGFloat = 1024
            while yOrigin < bounds.maxY {
                let imageBounds = CGRect(x: 0, y: yOrigin, width: pdfWidth, height: min(imageHeight, bounds.maxY - yOrigin))
                let img = drawing.image(from: imageBounds, scale: 2, userInterfaceStyle: .light)
                img.draw(in: imageBounds)
                yOrigin += imageHeight                
            }
                    
            UIGraphicsEndPDFContext()
                    
            completion(mutableData as Data, 0, visibleRectInPDF)
            
        }
        
    }
    
    func screenshotService(_ screenshotService: UIScreenshotService, generatePDFRepresentationWithCompletion completion: @escaping (_ PDFData: Data?, _ indexOfCurrentPage: Int, _ rectInCurrentPage: CGRect) -> Void) {
        
        drawingToPDF { (data, indexOfCurrentPage, rectInCurrentPage) in
            completion(data, indexOfCurrentPage, rectInCurrentPage)
        }
            
    }
    
}


extension DrawViewController: PKToolPickerObserver {
    
    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
    
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        updateLayout(for: toolPicker)
    }
        
    
    func updateLayout(for toolPicker: PKToolPicker) {
        let obscuredFrame = toolPicker.frameObscured(in: view)
        
        if obscuredFrame.isNull {
            canvasView.contentInset = .zero
        } else {
            canvasView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: view.bounds.maxX - obscuredFrame.minY, right: 0)
        }
        
        canvasView.scrollIndicatorInsets = canvasView.contentInset
        
        if isUndoEnabled != !obscuredFrame.isNull {
            isUndoEnabled = !obscuredFrame.isNull
            reloadNavigationItems()
        }
        
    }
    
}
