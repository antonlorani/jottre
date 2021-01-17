//
//  Settings.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import os.log

struct SettingsCodable: Codable {
    
    var usesCloud: Bool = false
    
    var language: Int = 0
    
    var preferedAppearance: Int = 0
    
}


class Settings: NSObject {
    
    // MARK: - Properties
    
    var settingsCodable: SettingsCodable!
    
    var url: URL? {
        return URL(string: "")
    }
    
    private var serializationQueue = DispatchQueue(label: "SettingsSerializationQueue", qos: .background)
    
    
    
    // MARK: - Init
    
    override init() {
        super.init()
        pull()
    }
    
    
    
    // MARK: - Methods
        
    /// Loading Settings from file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func pull(completion: ((Bool) -> Void)? = nil) {
        
        serializationQueue.async {
            
            guard let url = self.url else {
                return
            }
            
            guard FileManager.default.fileExists(atPath: url.path) else {
                Logger.main.debug("File \(url.path) does not exist")
                completion?(false)
                return
            }
            
            do {
                let decoder = PropertyListDecoder()
                let data = try Data(contentsOf: url)
                self.settingsCodable = try decoder.decode(SettingsCodable.self, from: data)
            } catch {
                Logger.main.error("Could not read node from file: \(url.path)")
                completion?(false)
            }
                                    
            completion?(true)
            
        }
        
    }
    
    
    /// Writing Settings to file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: ((Bool) -> Void)? = nil) {
        
        serializationQueue.async {
            
            guard let settingsCodable = self.settingsCodable, let url = self.url else {
                completion?(false)
                return
            }
            
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(settingsCodable)
                try data.write(to: url)
            } catch {
                Logger.main.error("Could not write NodeCodable to file: \(error.localizedDescription)")
                completion?(false)
            }
            
            completion?(true)
            
        }
        
    }
    
}
