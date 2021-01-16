//
//  UIDevice.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

extension UIDevice {
    
    static let isNotLimited = UIDevice.current.userInterfaceIdiom != .mac && UIDevice.current.userInterfaceIdiom != .phone
    
    static let isLimited = UIDevice.current.userInterfaceIdiom == .mac || UIDevice.current.userInterfaceIdiom == .phone

}
