//
//  ExportActions.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import os.log

extension DrawViewController {
    
    func createExportToPDFAction() -> UIAlertAction {
        return UIAlertAction(title: "PDF", style: .default, handler: { (action) in
            
            self.drawingToPDF { (data, _, _) in
                
                guard let data = data else {
                    Logger.main.debug("Could not create PDF from canvas")
                    return
                }
                
                let activityViewController = UIActivityViewController(activityItems: [data], applicationActivities: nil)
                
                DispatchQueue.main.async {
                    self.presentActivityViewController(activityViewController: activityViewController)
                }
                
            }
            
        })
    }
    
    func createExportToPNGAction() -> UIAlertAction {
        return UIAlertAction(title: "PNG", style: .default, handler: { (action) in
            
            guard let drawing = self.node.nodeCodable?.drawing else {
                return
            }
            
            var bounds = drawing.bounds
                bounds.size.height = drawing.bounds.maxY + 100
            
            let image = drawing.image(from: bounds, scale: 1)
            
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            self.presentActivityViewController(activityViewController: activityViewController)
            
        })
    }
    
    func createExportToJPGAction() -> UIAlertAction {
        return UIAlertAction(title: "JPG", style: .default, handler: { (action) in
            
            guard let drawing = self.node.nodeCodable?.drawing else {
                return
            }
            
            var bounds = drawing.bounds
                bounds.size.height = drawing.bounds.maxY + 100
            
            guard let image = drawing.image(from: bounds, scale: 1).jpegData(compressionQuality: 1) else {
                Logger.main.debug("Could not retrieve jpeg data from drawing")
                return
            }
            
            let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            self.presentActivityViewController(activityViewController: activityViewController)
            
        })
    }
    
    func createShareAction() -> UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("Share", comment: ""), style: .default, handler: { (action) in
            
            self.node.push()
            
            guard let url = self.node.url else {
                return
            }
            
            let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            self.presentActivityViewController(activityViewController: activityViewController)
            
        })
    }
    
    fileprivate func presentActivityViewController(activityViewController: UIActivityViewController, animated: Bool = true) {
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        self.present(activityViewController, animated: animated, completion: nil)
    }
    
}


