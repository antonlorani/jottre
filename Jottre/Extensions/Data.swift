//
//  Data.swift
//  Jottre
//
//  Created by Anton Lorani on 03.02.21.
//

import Foundation

extension Data {
    
    func writeToReturingBoolean(url: URL) -> Bool {
        
        do {
            try self.write(to: url)
            return true
        } catch {
            return false
        }
        
    }
    
}
