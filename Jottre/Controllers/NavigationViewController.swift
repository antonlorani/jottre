//
//  InitialNavigationViewController.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import UIKit

class NavigationViewController: UINavigationController {
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        updateNavigationBarBackground()
        
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateNavigationBarBackground()
    }
    
    
    
    // MARK: - Methods
    
    func setupViews() {
                        
        navigationItem.title = "Jottre"
        navigationBar.prefersLargeTitles = true
        view.backgroundColor = .white
        
    }
    
    
    func updateNavigationBarBackground() {

        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIColor.secondarySystemBackground.withAlphaComponent(0.95).set()
        UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        navigationBar.setBackgroundImage(UIGraphicsGetImageFromCurrentImageContext(), for: .default)
        UIGraphicsEndImageContext()

    }
    
}
