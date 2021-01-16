//
//  Logger.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import os.log

extension Logger {
    
    private static var subsystem = Bundle.main.bundleIdentifier!

    static let main = Logger(subsystem: subsystem, category: "main")
    
}
