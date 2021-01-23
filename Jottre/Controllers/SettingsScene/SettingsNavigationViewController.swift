//
//  SettingsNavigationViewController.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import UIKit

class SettingsNavigationViewController: UINavigationController {
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
    }
    
    
    
    // MARK: - Methods
    
    func setupViews() {
               
        modalPresentationStyle = .formSheet
        
        navigationItem.title = "Settings"
        navigationBar.prefersLargeTitles = true
        
    }
    
}
