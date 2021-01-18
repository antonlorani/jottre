//
//  IconSettingsCell.swift
//  Jottre
//
//  Created by Anton Lorani on 18.01.21.
//

import Foundation
import UIKit

class IconSettingsCell: SettingsCell {
    
    override func setupViews() {
        super.setupViews()
        
        imageView.constraints.forEach({ imageView.removeConstraint($0) })
        
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.label.cgColor
        
    }
    
}
