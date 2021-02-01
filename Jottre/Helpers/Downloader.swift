//
//  Downloader.swift
//  Jottre
//
//  Created by Anton Lorani on 22.01.21.
//

import Foundation
import OSLog

class Downloader {
    
    // MARK: - Properties
    
    var url: URL?
    
    static var isCloudEnabled: Bool {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil) != nil
    }
    
    
    
    // MARK: - Init
    
    init(url: URL) {
        self.url = url
    }
    
    
    
    // MARK: - Methods
    
    /// Starts force downloads file from iCloud Drive (If file exists)
    /// - Parameter completion: Returns true if download is completed
    func execute(completion: ((Bool) -> Void)? = nil) {

        guard let url = self.url else {
            completion?(false)
            return
        }
        
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
            handleProgress { (success) in
                if success {
                    completion?(true)
                }
            }
        } catch {
            completion?(false)
        }
        
    }
    
    
    // TODO: - Add timeout
    /// Looks at the current progress of a downloading file (Initialized via startDownloadingUbiquitousItem)
    /// - Parameter completion: Returns true if download is completed. False if download failed
    private func handleProgress(completion: ((Bool) -> Void)? = nil) {
        
        guard let url = self.url else {
            completion?(false)
            return
        }

        DispatchQueue.main.async {
            
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in

                guard let status = Downloader.getStatus(url: url) else {
                    completion?(false)
                    return
                }
                
                if status == URLUbiquitousItemDownloadingStatus.current {
                    timer.invalidate()
                    completion?(true)
                }
                
            })
            
        }
        
    }
    
    
    /// Method that returns the status of the current file-url (current, download or not downloaded)
    /// - Returns: URLUbiquitousItemDownloadingStatus. This value will indiciate the status of the file in the file-system
    static func getStatus(url: URL?) -> URLUbiquitousItemDownloadingStatus? {
        
        guard let url = url else {
            return nil
        }
        
        do {
            let attributes = try url.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
        
            guard let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus else {
                return nil
            }
            
            return status
        } catch {
            return nil
        }
        
    }
    
}
