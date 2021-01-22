//
//  Downloader.swift
//  Jottre
//
//  Created by Anton Lorani on 22.01.21.
//

import Foundation
import os.log

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
    
    func execute(completion: ((Bool) -> Void)? = nil) {
        
        guard let url = self.url else {
            completion?(false)
            return
        }
        
        Logger.main.debug("Starting download for: \(url)")
        
        do {
            try FileManager.default.startDownloadingUbiquitousItem(at: url)
            handleProgress { (success) in
                completion?(success)
            }
        } catch {
            Logger.main.debug("Download failed")
            completion?(false)
        }
        
    }
    
    
    func handleProgress(completion: ((Bool) -> Void)? = nil) {
        guard let url = self.url else {
            completion?(false)
            return
        }

        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (timer) in

                do {
                    
                    let attributes = try url.resourceValues(forKeys: [URLResourceKey.ubiquitousItemDownloadingStatusKey])
                    
                    guard let status: URLUbiquitousItemDownloadingStatus = attributes.allValues[URLResourceKey.ubiquitousItemDownloadingStatusKey] as? URLUbiquitousItemDownloadingStatus else {
                        return
                    }

                    if status == URLUbiquitousItemDownloadingStatus.current {
                        timer.invalidate()
                        completion?(true)
                    }
                    
                } catch {
                    completion?(false)
                }
                
            })
        }
        
    }
    
}
