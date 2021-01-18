//
//  Settings.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import UIKit
import os.log

struct SettingsCodable: Codable {
    
    var usesCloud: Bool = false
    
    var preferedAppearance: Int = 0 /// - 0=dark, 1=light, 2=system
    
}


protocol SettingsObserver {
    func settingsDidChange(_ settings: Settings)
}

class Settings: NSObject {
    
    // MARK: - Properties
    
    var settingsCodable: SettingsCodable!
    
    var observers: [SettingsObserver] = []
        
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
            
            if UserDefaults.standard.data(forKey: "settings") == nil {
                self.createSettings()
                return
            }
            
            do {
                let decoder = PropertyListDecoder()
                let data = UserDefaults.standard.data(forKey: "settings")!
                self.settingsCodable = try decoder.decode(SettingsCodable.self, from: data)
            } catch {
                completion?(false)
            }
            
            self.didUpdate()
            completion?(true)
            
        }
        
    }
    
    
    /// Writing Settings to file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: ((Bool) -> Void)? = nil) {
        
        serializationQueue.async {
            
            guard let settingsCodable = self.settingsCodable else {
                completion?(false)
                return
            }
            
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(settingsCodable)
                UserDefaults.standard.set(data, forKey: "settings")
            } catch {
                Logger.main.error("Could not write NodeCodable to file: \(error.localizedDescription)")
                completion?(false)
            }
            
            completion?(true)
            
        }
        
    }
    
    
    /// Generates a .settings file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func createSettings(completion: ((Bool) -> Void)? = nil) {
        Logger.main.info("Creating settings file")
        
        settingsCodable = SettingsCodable(usesCloud: UIDevice.isLimited(), preferedAppearance: 2)
        push { (success) in
            completion?(success)
        }
        
    }
    
    
    
    // MARK: - Set methods
    
    func set(preferedAppearance: Int) {
        self.settingsCodable.preferedAppearance = preferedAppearance
        push()
        didUpdate()
    }
    
    
    func set(usesCloud: Bool) {
        self.settingsCodable.usesCloud = usesCloud
        push()
        didUpdate()
    }
    
    
    
    // MARK: - Observer methods
    
    /// Sends a message to each observer, that there happened changes inside this object.
    func didUpdate() {
        DispatchQueue.main.async {
            self.observers.forEach({ $0.settingsDidChange(self) })
        }
    }
    
    
    func addObserver(_ observer: SettingsObserver) {
        observers.append(observer)
    }
    
}
