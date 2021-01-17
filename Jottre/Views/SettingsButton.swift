//
//  SettingsButton.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import UIKit

class SettingsButton: UIButton {
    
    // MARK: - Init
    
    init(target: Any, action: Selector) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        self.addTarget(target, action: action, for: .touchUpInside)
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
        
        setImage(UIImage(systemName: "gear"), for: .normal)
        
        tintColor = UIColor.white
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
    }
    
}

