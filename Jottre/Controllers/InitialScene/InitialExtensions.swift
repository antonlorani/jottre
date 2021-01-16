//
//  InitialViewControllerExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import os.log


// MARK: - NodeCollector

extension InitialViewController: NodeCollectorObserver {
    
    func nodeCollectorDidChange() {
        collectionView.reloadData()
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
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        
        Logger.main.debug("Request for showing Node in detail")
        
    }
    
}

