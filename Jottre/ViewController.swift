//
//  ViewController.swift
//  Jottre
//
//  Created by Anton Lorani on 19.01.21.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        test()
        
    }
    
    
    func test() {
        
        settings.set(usesCloud: true)
        
        let files = try! FileManager.default.contentsOfDirectory(atPath: NodeCollector.path().path)

        print(files)
        
    }
    
}
