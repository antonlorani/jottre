//
//  NodeExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 02.02.21.
//

import Foundation

extension Node {
    
    func push() { push { (_) in } }
    
    func prepareData() { prepareData { (_) in } }
    
    func pullData() { pullData { (_) in } }
    
    func pull() { pull { (_) in } }
    
    func pullHandler() { pullHandler { (_) in } }
    
    func updateMeta() { updateMeta { (_) in } }
    
}
