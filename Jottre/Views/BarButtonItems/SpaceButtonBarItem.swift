//
//  SpaceButtonBarItem.swift
//  Jottre
//
//  Created by Anton Lorani on 02.03.21.
//

import UIKit

class SpaceButtonBarItem: CustomButtonBarItem {
    
    // MARK: - Main
    
    init() {
        super.init(target: nil, action: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Methods
    
    override func setupViews() {
        super.setupViews()
        
        backgroundColor = .clear
        
    }
    
    
}
