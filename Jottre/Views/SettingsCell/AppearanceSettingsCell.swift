//
//  AppearanceSettingsCell.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import UIKit

class AppearanceSettingsCell: SettingsCell {
    
    // MARK: - Subviews
    
    var colorLabel: UILabel = {
        let darkAppearance = NSLocalizedString("Dark", comment: "Dark appearance")
        let systemAppearance = NSLocalizedString("System", comment: "System appearance")

        var title = NSLocalizedString("Light", comment: "Light appearance")
        
        if settings.codable.preferedAppearance == 0 {
            title = darkAppearance
        } else if settings.codable.preferedAppearance == 2 {
            title = systemAppearance
        }
        
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            label.text = title
            label.textColor = .secondaryLabel
        return label
    }()
    
    
    
    // MARK: - Override methods
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(colorLabel)
        colorLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        colorLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        colorLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        colorLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        title = NSLocalizedString("Interface appearance", comment: "")
        
    }
    
}


