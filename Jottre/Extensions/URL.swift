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
    
    
    /// Checks if the file-path is a valid icloud file
    /// - Returns: True if file is a potential cloud file (Which then needs to be downloaded)
    func isCloud() -> Bool {
        return self.pathExtension == "icloud"
    }
    
    
    /// Converts the ugly iCloud file-path to a valid .jot path
    /// - Returns: Actual file-path for a readable node
    func cloudToJot() -> URL {
        if !isCloud() { return self }
        
        var tmpURL = self.deletingPathExtension()
        
        var tmpFileName = tmpURL.lastPathComponent
            tmpFileName.removeFirst()
        
        tmpURL.deleteLastPathComponent()
        tmpURL.appendPathComponent(tmpFileName)
        
        return tmpURL
    }
    
    
    /// Checks if the file-path is a valid icloud and jot file
    /// - Returns: True if file is a potential cloud file (Which then needs to be downloaded)
    func isCloudAndJot() -> Bool {
        if self.isCloud() {
            let tmpURL = self.deletingPathExtension()
            return tmpURL.isJot()
        }
        return false
    }
    
}
