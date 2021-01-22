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
        
    }
    
    
    
    // MARK: - Methods
    
    func setupViews() {
                        
        navigationItem.title = "Jottre"
        navigationBar.prefersLargeTitles = true
        
    }
    
}
