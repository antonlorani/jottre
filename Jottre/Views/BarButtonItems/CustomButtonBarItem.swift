//
//  CustomButtonBarItem.swift
//  Jottre
//
//  Created by Anton Lorani on 07.02.21.
//

import Foundation
import UIKit

class CustomButtonBarItem: UIButton {
    
    // MARK: - Init
    
    init(target: Any?, action: Selector?) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        
        if let target = target, let action = action {
            self.addTarget(target, action: action, for: .touchUpInside)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK: - Override methods
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupViews()
    }
    
    
    
    // MARK: - Methods
    
    func setupViews() {
        
        backgroundColor = .systemBlue
                
        tintColor = UIColor.white
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
    }
    
}

