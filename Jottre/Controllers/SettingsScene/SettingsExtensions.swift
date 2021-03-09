//
//  SettingsExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import UIKit

extension SettingsViewController: CloudSettingsCellDelegate {
    
    func didMoveSwitch(cell: CloudSettingsCell, to state: Bool) {
        settings.set(usesCloud: state)
    }
    
}

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
            return cell
            
        } else if indexPath.row == 1 {

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cloudSettingsCell", for: indexPath) as? CloudSettingsCell else {
                fatalError("Cell is not of type CloudSettingsCell")
            }
            cell.delegate = self
            cell.usesCloud = UIDevice.isLimited() ? true : settings.codable.usesCloud
            cell.switchView.isEnabled = !(UIDevice.isLimited() || !Downloader.isCloudEnabled)
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
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        if indexPath.row == 0 {
     
            guard let cell = cell as? AppearanceSettingsCell else { return }
            
            if settings.codable.preferedAppearance == 0 {
                cell.colorLabel.text = NSLocalizedString("Light", comment: "Light appearance")
                settings.set(preferedAppearance: 1)
            } else if settings.codable.preferedAppearance == 1 {
                cell.colorLabel.text = NSLocalizedString("System", comment: "System appearance")
                settings.set(preferedAppearance: 2)
            } else if settings.codable.preferedAppearance == 2 {
                cell.colorLabel.text = NSLocalizedString("Dark", comment: "Dark appearance")
                settings.set(preferedAppearance: 0)
            }
            
        } else if indexPath.row == 2 {

            guard let url = URL(string: "https://github.com/AntonAmes/jottre") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

        }
        
    }
    
}
