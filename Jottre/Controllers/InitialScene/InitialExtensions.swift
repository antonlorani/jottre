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
        collectionView.reloadData()
    }
    
    func didDeletedNode(nodeCollector: NodeCollector, at index: Int) {
        
        collectionView.performBatchUpdates({
            let indexPath = IndexPath(item: index, section: 0)
            self.collectionView.deleteItems(at: [indexPath])
        }, completion: nil)
        
    }
    
}



// MARK: - Settings

extension InitialViewController: SettingsObserver {
        
    func settingsDidChange(_ settings: Settings) {
        if initialLoad {
            initialLoad = false
            return
        }
        nodeCollector.update()
        nodeCollector.push()
        
    }
    
}



// MARK: - UICollectionView

extension InitialViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
        
        nodeCollector.nodes[indexPath.row].addObserver(cell)
        cell.node = nodeCollector.nodes[indexPath.row]
        
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
    
}

