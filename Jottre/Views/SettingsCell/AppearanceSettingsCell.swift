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
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            label.text = "Light"
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

    }
    
}


