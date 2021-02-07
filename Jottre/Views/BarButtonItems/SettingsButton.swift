//
//  SettingsButton.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import UIKit

class SettingsButton: CustomButtonBarItem {
    
    // MARK: - Override methods
    
    override func setupViews() {
        super.setupViews()
       
        setImage(UIImage(systemName: "gear"), for: .normal)
        
    }
    
}

