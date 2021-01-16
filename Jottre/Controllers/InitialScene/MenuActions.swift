//
//  MenuActions.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import os.log

extension InitialViewController {
    
    func createEditAction(indexPath: IndexPath) -> UIAction {
        return UIAction(title: "Edit", image: UIImage(systemName: "square.and.pencil")) { (action) in
            self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
        }
    }
    
    
    func createRenameAction(indexPath: IndexPath) -> UIAction {
        return UIAction(title: "Rename", image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis")) { (action) in
            
            guard let currentName = self.nodeCollector.nodes[indexPath.row].name, let url = self.nodeCollector.nodes[indexPath.row].url else {
                return
            }
            
            let alertController = UIAlertController(title: "Rename note", message: "Type in a new name for the selected note", preferredStyle: .alert)
                        
            alertController.addTextField { (textField) in
                textField.placeholder = currentName
            }
                        
            alertController.addAction(UIAlertAction(title: "Rename", style: UIAlertAction.Style.default, handler: { (action) in
                
                guard let textFields = alertController.textFields, var updatedName = textFields[0].text else {
                    return
                }
                updatedName = updatedName == "" ? currentName : updatedName
                
                self.nodeCollector.nodes[indexPath.row].rename(to: NodeCollector.computeCopyName(baseName: updatedName, path: url.deletingLastPathComponent()))
                
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    
    func createDeleteAction(indexPath: IndexPath) -> UIMenu {
        let (title, image) = ("Delete", UIImage(systemName: "trash"))
        
        let confirmDeleteAction = UIAction(title: "\(title)?", image: image, attributes: .destructive) { (action) in
            
            self.nodeCollector.disableObservers()
            self.nodeCollector.nodes[indexPath.row].delete { (success) in
                if !success { return }
                
                DispatchQueue.main.async {
                    
                    self.collectionView.performBatchUpdates {
                        self.collectionView.deleteItems(at: [indexPath])
                    } completion: { (_) in
                        self.nodeCollector.enableObservers()
                    }
                    
                }
                
            }
            
        }
        
        return UIMenu(title: title, image: image, options: .destructive, children: [confirmDeleteAction])
    }
    
}
