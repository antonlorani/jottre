//
//  URK.swift
//  Jottre
//
//  Created by Anton Lorani on 21.01.21.
//

import Foundation

extension URL {
    
    /// Checks if the file-path is a valid Jot
    /// - Returns: True if file is a potential jot
    func isJot() -> Bool {
        return self.pathExtension == "jot"
    }
    
}
