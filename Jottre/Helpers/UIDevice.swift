//
//  UIDevice.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

extension UIDevice {
    
    /// Checks if device can be to edit Jots
    /// - Returns: A boolish value that indicates potential limitations (Such as device is not an iPad)
    static func isLimited() -> Bool {
        
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return !(UIDevice.current.userInterfaceIdiom == .pad)
        #endif
        
    }
    
}
