//
//  NavigationButton.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

class NavigationTextButton: UILabel {
    
    // MARK: - Properties
    
    var title: String = "Button"
    
    private var tapGesture: UITapGestureRecognizer!
    
    
    
    // MARK: - Init
    
    init(title: String, target: Any, action: Selector) {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: 30)))
        
        self.title = title
        
        self.tapGesture = UITapGestureRecognizer(target: target, action: action)
        self.tapGesture.numberOfTouchesRequired = 1
        self.tapGesture.numberOfTapsRequired = 1
        
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
        
        addGestureRecognizer(tapGesture)
        
        backgroundColor = .systemBlue
        
        isUserInteractionEnabled = true
        
        textColor = .white
        text = title
        textAlignment = .center
                
        font = UIFont.boldSystemFont(ofSize: 18)
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        frame.size.width = title.width(inside: self) + 20
        
    }
    
}
