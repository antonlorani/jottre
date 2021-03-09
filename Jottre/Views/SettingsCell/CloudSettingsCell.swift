//
//  CloudSettingsCell.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import UIKit
import OSLog

protocol CloudSettingsCellDelegate {
    
    func didMoveSwitch(cell: CloudSettingsCell, to state: Bool)
    
}


class CloudSettingsCell: SettingsCell {
    
    // MARK: - Properties
    
    var delegate: CloudSettingsCellDelegate?
    
    var usesCloud: Bool = false {
        didSet {
            switchView.setOn(usesCloud, animated: true)
        }
    }
    
    
    
    // MARK: - Subviews
    
    var switchView: UISwitch = {
        let switchView = UISwitch()
            switchView.translatesAutoresizingMaskIntoConstraints = false
            switchView.onTintColor = UIColor.systemBlue
        return switchView
    }()
    
    
    
    // MARK: - Override methods
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(switchView)
        switchView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        switchView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        switchView.widthAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        switchView.heightAnchor.constraint(greaterThanOrEqualToConstant: 10).isActive = true
        
        title = NSLocalizedString("Synchronize with iCloud", comment: "")
        
        if UIDevice.isLimited() || !Downloader.isCloudEnabled {
            switchView.isEnabled = false
        }
        
        setupDelegates()
        
    }
 
    
    func setupDelegates() {
        switchView.addTarget(self, action: #selector(self.handleSwitch), for: .valueChanged)
    }
    
    
    @objc func handleSwitch() {
        delegate?.didMoveSwitch(cell: self, to: switchView.isOn)
    }
    
}
