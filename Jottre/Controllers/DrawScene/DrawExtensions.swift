//
//  DrawExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import PencilKit

extension DrawViewController: PKCanvasViewDelegate {
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        hasModifiedDrawing = true
        updateContentSizeForDrawing()
    }
    
}


extension DrawViewController: UIScreenshotServiceDelegate {
    
    func drawingToPDF(_ completion: @escaping (_ PDFData: Data?, _ indexOfCurrentPage: Int, _ rectInCurrentPage: CGRect) -> Void) {
        
        let drawing = canvasView.drawing
        let visibleRect = canvasView.bounds
        
        let pdfWidth: CGFloat = node.nodeCodable!.width
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
                let img = drawing.image(from: imageBounds, scale: 2)
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
