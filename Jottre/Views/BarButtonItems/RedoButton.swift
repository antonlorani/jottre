//
//  RedoButton.swift
//  Jottre
//
//  Created by Anton Lorani on 02.03.21.
//

import UIKit

class RedoButton: CustomButtonBarItem {
    
    // MARK: - Properties
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                backgroundColor = .systemGray5
                tintColor = .lightGray
            } else {
                backgroundColor = .systemGray4
                tintColor = .systemGray
            }
        }
    }
    
    
    
    // MARK: - Override Methods
    
    override func setupViews() {
        super.setupViews()
       
        setImage(UIImage(systemName: "arrow.uturn.forward", withConfiguration: UIImage.SymbolConfiguration(pointSize:15, weight: .semibold)), for: .normal)
        isEnabled = !(!isEnabled)

    }
    
}
