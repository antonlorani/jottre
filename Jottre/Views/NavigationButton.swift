//
//  NavigationButton.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

class NavigationButton: UIButton {
    
    // MARK: - Properties
    
    var title: String = "Button"
    
    
    
    // MARK: - Init
    
    init(title: String, target: Any, action: Selector) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 30)))
        self.addTarget(target, action: action, for: .touchUpInside)
        self.title = title
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
        
        setTitleColor(.white, for: .normal)
        setTitle(title, for: .normal)
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        frame.size.width = title.width(inside: self) + 20
        
    }
    
}
