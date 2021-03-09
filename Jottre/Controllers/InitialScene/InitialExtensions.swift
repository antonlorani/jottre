//
//  InitialViewControllerExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import OSLog


// MARK: - NodeCollector

extension InitialViewController: NodeCollectorObserver {
    
    func didInsertNode(nodeCollector: NodeCollector, at index: Int) {
        
        collectionView.performBatchUpdates({
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.insertItems(at: [indexPath])
        }, completion: nil)

    }
    
    func didDeleteNode(nodeCollector: NodeCollector, at index: Int) {
        
        collectionView.performBatchUpdates({
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        
    }
    
}



// MARK: - Settings

extension InitialViewController {
        
    @objc func settingsDidChange(_ notification: Notification) {
        if initialLoad {
            initialLoad = false
            return
        }
        nodeCollector.update()
        nodeCollector.push()
        
    }
    
}



// MARK: - UICollectionView

extension InitialViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        hasDocuments = nodeCollector.nodes.count != 0
        return nodeCollector.nodes.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nodeCell", for: indexPath) as? NodeCell else {
            fatalError("Cell is not of type NodeCell.")
        }
        cell.node = nodeCollector.nodes[indexPath.row]
        cell.node.observer = cell
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let drawController = DrawViewController(node: nodeCollector.nodes[indexPath.row])
        navigationController?.pushViewController(drawController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
            self.nodeCollector.continueBackgroundFetch()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        nodeCollector.pauseBackgroundFetch()
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (actions) -> UIMenu? in
            
            let actions = [
                self.createEditAction(indexPath: indexPath),
                self.createRenameAction(indexPath: indexPath),
                self.createDeleteAction(indexPath: indexPath)
            ]
            
            return UIMenu(title: "", children: actions)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let minWidth: CGFloat = 232
        let numberOfColumns: Int = Int((view.frame.width - 40) / minWidth)
        let space: CGFloat = (view.frame.width - 40).truncatingRemainder(dividingBy: minWidth)
        
        var width: CGFloat = minWidth
        
        if numberOfColumns == 1 {
            width = view.frame.width - 40
        } else {
            let spaces: CGFloat = 15 * CGFloat(numberOfColumns)
            width = minWidth + (space - spaces) / CGFloat(numberOfColumns)
        }
        
        return CGSize(width: width, height: 291)
    }
    
}

extension InitialViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        var dragItems = [UIDragItem]()
        let selectedNode = nodeCollector.nodes[indexPath.row]
        if let imageToDrag = selectedNode.thumbnail {
            
            let userActivity = selectedNode.openDetailUserActivity

            let itemProvider = NSItemProvider(object: imageToDrag)
                itemProvider.registerObject(userActivity, visibility: .all)
            
            let dragItem = UIDragItem(itemProvider: itemProvider)
                dragItem.localObject = selectedNode
                dragItems.append(dragItem)
            
        }
        
        return dragItems
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        var dragItems = [UIDragItem]()
        let selectedNode = nodeCollector.nodes[indexPath.row]
        if let imageToDrag = selectedNode.thumbnail {
            
            let userActivity = selectedNode.openDetailUserActivity

            let itemProvider = NSItemProvider(object: imageToDrag)
                itemProvider.registerObject(userActivity, visibility: .all)
            
            let dragItem = UIDragItem(itemProvider: itemProvider)
                dragItem.localObject = selectedNode
                dragItems.append(dragItem)
            
        }
        
        return dragItems
    }
    
}
