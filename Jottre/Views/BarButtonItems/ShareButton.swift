//
//  ShareButton.swift
//  Jottre
//
//  Created by Anton Lorani on 07.02.21.
//

import Foundation
import UIKit

class ShareButton: CustomButtonBarItem {
    
    // MARK: - Override Methods
    
    override func setupViews() {
        super.setupViews()
       
        setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        
    }
    
}
