//
//  Node.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import PencilKit
import OSLog


protocol NodeObserver {
    func didUpdate(node: Node)
}

struct NodeObserverReusable {
    
    var reuseIdentifier: String
    
    var observer: NodeObserver
    
}



/// This class will manage the processes of a NodeCodable
/// This includes: encoding, decoding and basic file system related methods
class Node: NSObject {
    
    // MARK: - Properties
    
    var name: String?
    
    var isOpened: Bool = false
        
    var url: URL? {
        didSet {
            guard let url = url else { return }
            name = url.deletingPathExtension().lastPathComponent
        }
    }
    
    var status: URLUbiquitousItemDownloadingStatus? {
        return Downloader.getStatus(url: self.url)
    }
    
    private var observersEnabledValue: Bool = true
    
    var observersEnabled: Bool {
        return observersEnabledValue
    }
    
    var initialDataHash: Int?
    
    var currentDataHash: Int?
    
    var thumbnail: UIImage?
    
    var codable: NodeCodableV2?
    
    var collector: NodeCollector?
    
    var observer: NodeObserver?
    
    var observers: [NodeObserverReusable] = []
    
    private var serializationQueue = DispatchQueue(label: "NodeSerializationQueue", qos: .background)
    
    
    static let NodeOpenDetailActivityType = "com.antonlorani.jottre.openDetail"
    
    static let NodeOpenDetailPath = "openDetail"
    
    static let NodeOpenDetailIdKey = "nodeURL"
    
    var openDetailUserActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: Node.NodeOpenDetailActivityType)
            userActivity.title = Node.NodeOpenDetailPath
            userActivity.userInfo = [Node.NodeOpenDetailIdKey: url!]
            userActivity.requiredUserInfoKeys = [Node.NodeOpenDetailIdKey]
        return userActivity
    }
    
    
    
    // MARK: - Init
    
    /// Initializer for a Node from a custom url
    /// - Parameter url: Should point to a .jot file on the users file-system
    init(url: URL) {
        super.init()
        setupValues(url: url, nodeCodable: NodeCodableV2())
    }
    
    
    /// Helper method for the initializer
    /// - Parameters:
    ///   - url: url passed via initializer
    ///   - nodeCodable: A valid NodeCodable object
    private func setupValues(url: URL, nodeCodable: NodeCodableV2) {
        self.url = url
        self.codable = nodeCodable
    }
    
    
    
    // MARK: - Methods
    
    /// Prepares pull of the node from drive.
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func pull(completion: @escaping (_ success: Bool) -> Void) {
        
        serializationQueue.async {
            
            guard let url = self.url else {
                completion(false)
                return
            }
                
            if !url.isCloudAndJot() && !url.isJot() {
                completion(false)
                return
            }
                
            if !settings.codable.usesCloud {
                self.pullHandler { (success) in
                    completion(success)
                }
                return
            }
                
            guard let status = self.status else {
                completion(false)
                return
            }
                
            if status == .current {
                self.pullHandler { (success) in
                    completion(success)
                }
                return
            }

            let downloader = Downloader(url: url)
            downloader.execute { (success) in

                if !success {
                    Logger.main.error("Could not download node from file: \(url.path)")
                    completion(false)
                    return
                }

                self.url = url.cloudToJot()

                self.pullHandler { (success) in
                    completion(success)
                }

            }
            
        }
        
    }
    
        
    /// Loads the Node from file
    /// - Parameter url: URL to load the file from.
    func pullHandler(completion: @escaping (_ success: Bool) -> Void) {
        
        serializationQueue.async {
            
            guard let url = self.url, FileManager.default.fileExists(atPath: url.path) else {
                completion(false)
                return
            }
            
            self.pullData { (data) in
                guard let data = data else {
                    completion(false)
                    return
                }
                
                guard let decodedCodable = self.decode(from: data) else {
                    completion(false)
                    return
                }
                
                if !self.isOpened {
                    self.initialDataHash = data.hashValue
                }
                
                self.codable = decodedCodable
                
                completion(true)
                
            }
            
        }
        
    }
    
    
    /// Pulls the file-data from given url
    /// - Parameters:
    ///   - completion: Returns boolean that indicates success or failure. Data is nil if fetch failed.
    func pullData(completion: @escaping (_ data: Data?) -> Void) {
        
        guard let url = self.url, FileManager.default.fileExists(atPath: url.path) else {
            completion(nil)
            return
        }
        
        serializationQueue.async {
            
            do {
                let data = try Data(contentsOf: url)
                completion(data)
            } catch {
                completion(nil)
            }
            
        }
        
    }
    
    
    /// Helper method that serializes the codable object to data
    /// - Returns: If success the codable as data. If failure nil.
    func prepareData(completion: @escaping (_ data: Data?) -> Void) {
        
        guard let nodeCodable = self.codable else {
            completion(nil)
            return
        }
        
        serializationQueue.async {
            
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(nodeCodable)
                completion(data)
                return
            } catch {
                completion(nil)
                return
            }
            
        }
        
    }
    
    
    /// Writing Node to file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: @escaping (_ success: Bool) -> Void) {
        
        serializationQueue.async {
            
            guard let url = self.url else {
                completion(false)
                return
            }
            
            self.prepareData { (data) in
                guard let data = data else {
                    completion(false)
                    return
                }
                
                do {
                    try data.write(to: url)
                    self.initialDataHash = data.hashValue
                } catch {
                    Logger.main.error("Could not write data to file: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                _ = self.moveFilesIfNeeded()
                completion(true)
                
            }
            
        }
        
    }
    
    
    /// Moves drawing to Node. Calls update to generate thumbnail
    /// - Parameter drawing: Given PKDrawing
    func setDrawing(drawing: PKDrawing) {
        
        codable?.drawing = drawing
        codable?.lastModified = NSDate().timeIntervalSince1970
        
        didUpdate()
        push()
        
    }
    
    
    /// Sends a message to each observer, that there happened changes inside this object.
    func didUpdate() {
        
        if !observersEnabled { return }
        
        DispatchQueue.main.async {
            self.observer?.didUpdate(node: self)
            self.observers.forEach({ $0.observer.didUpdate(node: self) })
        }
        
    }
    
    
    
    // MARK: - Observer methods
    
    /// Enable observer calls ;)
    func enableObservers() {
        observersEnabledValue = true
    }
    
    
    /// Suppresses the observer calls ;)
    func disableObservers() {
        observersEnabledValue = false
    }
    
    
    /// Adds a new observer to this class
    /// - Parameters:
    ///   - observer: NodeObserver class that listens for a possible Node-update
    ///   - reuseIdentifier: A unique string that is used to release the observer from the node.
    func addObserver(_ observer: NodeObserver, _ reuseIdentifier: String) {
        observers.append(NodeObserverReusable(reuseIdentifier: reuseIdentifier, observer: observer))
    }


    /// Removes an existing observer from this class
    func deleteObserver(_ observer: NodeObserver, _ reuseIdentifier: String) {
        observers.removeAll { (reusableObserver) -> Bool in
            return reusableObserver.reuseIdentifier == reuseIdentifier
        }
    }
    
    
}
