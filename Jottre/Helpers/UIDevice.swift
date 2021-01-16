//
//  UIDevice.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

extension UIDevice {
    
    static func isLimited() -> Bool {
        
        #if targetEnvironment(macCatalyst)
            return true
        #else
            return !(UIDevice.current.userInterfaceIdiom == .pad)
        #endif
        
    }
    
}
