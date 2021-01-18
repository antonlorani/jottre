//
//  SettingsExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import UIKit

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 60)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "appearanceSettingsCell", for: indexPath) as? AppearanceSettingsCell else {
                fatalError("Cell is not of type AppearanceSettingsCell")
            }
            cell.title = "Interface appearance"
            return cell
            
        } else if indexPath.row == 1 {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cloudSettingsCell", for: indexPath) as? CloudSettingsCell else {
                fatalError("Cell is not of type CloudSettingsCell")
            }
            cell.title = "Synchronize with iCloud"
            cell.usesCloud = false
            return cell
            
        } else if indexPath.row == 2 {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsCell", for: indexPath) as? SettingsCell else {
                fatalError("Cell is not of type SettingsCell")
            }
            cell.title = "Github repository"
            cell.image = UIImage(systemName: "arrow.up.right.square.fill")!
            return cell
            
        }
        
        return UICollectionViewCell()
    }
    
}
