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
    
    func nodeCollectorDidChange() {
        self.collectionView.reloadData()
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
        cell.node = nodeCollector.nodes[indexPath.row]
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let drawController = DrawViewController(node: nodeCollector.nodes[indexPath.row])
        navigationController?.pushViewController(drawController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
            self.nodeCollector.startBackgroundFetch()
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

