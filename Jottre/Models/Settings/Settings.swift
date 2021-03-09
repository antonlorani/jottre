//
//  Settings.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import Foundation
import UIKit
import OSLog

struct SettingsCodable: Codable {
    
    var usesCloud: Bool = false
    
    var preferedAppearance: Int = 0 /// 0=dark, 1=light, 2=auto
    
}


class Settings: NSObject {
    
    // MARK: - Properties
    
    var codable: SettingsCodable!
        
    public static let tmpDirectory: URL = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
    
    public static let didUpdateNotificationName = Notification.Name("didUpdateSettings")
    
    
    
    // MARK: - Init
    
    override init() {
        super.init()
        _ = pull()
    }
    
    
    
    // MARK: - Methods
        
    /// Loading Settings from file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func pull() -> Bool {
        
        if UserDefaults.standard.data(forKey: "settings") == nil {
            createSettings()
            return true
        }
            
        do {
            let decoder = PropertyListDecoder()
            let data = UserDefaults.standard.data(forKey: "settings")!
            self.codable = try decoder.decode(SettingsCodable.self, from: data)
        } catch {
            return false
        }
            
        didUpdate()
        return true
        
    }
    
    
    /// Writing Settings to file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push() -> Bool {
                    
        guard let codable = self.codable else {
            return false
        }
            
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(codable)
            UserDefaults.standard.set(data, forKey: "settings")
        } catch {
            Logger.main.error("Could not write NodeCodable to file: \(error.localizedDescription)")
            return false
        }
            
        return true
        
    }
    
    
    /// Generates a .settings file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func createSettings(completion: ((Bool) -> Void)? = nil) {
        Logger.main.info("Creating settings file")
        
        codable = SettingsCodable(usesCloud: UIDevice.isLimited(), preferedAppearance: 2)
        _ = push()
        
    }
    
    
    
    // MARK: - Set methods
    
    /// Sets the appearance
    /// - Parameter preferedAppearance: 0 = dark, light = 1, auto = 2
    func set(preferedAppearance: Int) {
        self.codable.preferedAppearance = preferedAppearance
        _ = push()
        didUpdate()
    }
    
    
    /// Sets a boolish value that indicates wether the files were loaded/stored localy or via iCloud Driver
    /// - Parameter usesCloud: -
    func set(usesCloud: Bool) {
        self.codable.usesCloud = usesCloud
        _ = push()
        didUpdate()
    }
    
    
    
    // MARK: - Get methods
    
    /// Returns a preferedUserInterfaceStyle object (Depending on the settings.codable.preferedAppearance property)
    /// - Returns: Prefered appearance as UIUserInterfaceStyle object
    func preferredUserInterfaceStyle() -> UIUserInterfaceStyle {
        if self.codable.preferedAppearance == 0 {
            return UIUserInterfaceStyle.dark
        } else if self.codable.preferedAppearance == 1 {
            return UIUserInterfaceStyle.light
        } else if self.codable.preferedAppearance == 2 {
            return UIUserInterfaceStyle.unspecified
        } else {
            return UIUserInterfaceStyle.unspecified
        }
    }
    
    
    /// Returns the correct primaryBackgroundColor for the selected preferredUserInterface
    /// - Returns: Prefered appearance as UIColor object
    func preferredUserInterfaceBackgroundColor() -> UIColor {
        if settings.preferredUserInterfaceStyle() == .dark {
            return UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        } else if settings.preferredUserInterfaceStyle() == .light {
            return UIColor.white
        } else {
            return UIColor.systemBackground
        }
    }
    
    
    
    /// Returns the "root" path of this application. (Depending of user-prefered storage (local vs iCloud))
    /// - Returns: Main directory-path. This is the directory where the files were primarly stored.
    /// - Discussion: 
    func getPath() -> URL {

        if codable == nil {
            _ = pull()
        }
        
        if codable.usesCloud {
            guard let url = Settings.getCloudPath() else {
                return Settings.getLocalPath()
            }
            return url
        } else {
            return Settings.getLocalPath()
        }

    }
    
    
    /// Returns the root iCloud path for the Jottre Container
    /// - Returns: Local iCloud path
    static func getCloudPath() -> URL? {
        guard let url = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") else {
            return nil
        }
        
        var isDirectory = ObjCBool(true)
        
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false)
                return url
            } catch {
                Logger.main.error("Could not create directory at \(url.path)")
                return nil
            }
            
        }
        
        return url
    }
    
    
    /// Returns the root local path for the Jottre Container
    /// - Returns: Local path
    static func getLocalPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    
    
    // MARK: - Observer methods
    
    /// Sends a message to each observer, that there happened changes inside this object.
    func didUpdate() {
        NotificationCenter.default.post(name: Settings.didUpdateNotificationName, object: self)
    }
    
}
