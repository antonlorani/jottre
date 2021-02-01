//
//  Node.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import PencilKit
import OSLog


/// A custom helper class that generates the thumbnails for a given Node
var thumbnailGenerator: ThumbnailGenerator = ThumbnailGenerator(size: CGSize(width: UIScreen.main.bounds.width >= (232 * 2 + 40) ? 232 : UIScreen.main.bounds.width - 4, height: 291))


/// This class will manage the processes of a NodeCodable
/// This includes: encoding, decoding and basic file system related methods
class Node: NSObject {
    
    // MARK: - Properties
    
    var name: String?
        
    var url: URL? {
        didSet {
            guard let url = url else { return }
            name = url.deletingPathExtension().lastPathComponent
        }
    }
    
    var status: URLUbiquitousItemDownloadingStatus? {
        return Downloader.getStatus(url: self.url)
    }
    
    var dataHash: Int?
    
    var thumbnail: UIImage?
    
    var codable: NodeCodableV2?
    
    var collector: NodeCollector?
    
    private var serializationQueue = DispatchQueue(label: "NodeSerializationQueue", qos: .background)
    
    
    
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
    func pull(completion: ((Bool) -> Void)? = nil) {
        
        serializationQueue.async {
            
            guard let url = self.url else {
                completion?(false)
                return
            }
            
            if !url.isCloudAndJot() && !url.isJot() {
                completion?(false)
                return
            }
            
            if !settings.codable.usesCloud {
                self.pullHandler(url: url) { (success) in
                    completion?(success)
                }
                return
            }
            
            guard let status = self.status else {
                completion?(false)
                return
            }
            
            if status == .current {
                self.pullHandler(url: url) { (success) in
                    completion?(success)
                }
                return
            }

            let downloader = Downloader(url: url)
            downloader.execute { (success) in

                if !success {
                    Logger.main.error("Could not download node from file: \(url.path)")
                    completion?(false)
                    return
                }

                self.url = url.cloudToJot()

                self.pullHandler(url: self.url!) { (success) in
                    completion?(success)
                }

            }
            
        }
        
    }
    
    
    /// Loads the Node from file
    /// - Parameter url: URL to load the file from.
    func pullHandler(url: URL, completion: ((Bool) -> Void)? = nil) {
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            Logger.main.debug("File \(url.path) does not exist")
            completion?(false)
            return
        }
        
        Node.pullData(url: url) { (success, data) in
            
            guard let data = data, success != false else {
                completion?(false)
                return
            }
            
            guard let codable = self.decode(from: data) else {
                return
            }
            
            self.codable = codable
            self.dataHash = data.hashValue
            
            self.updateMeta()
            
            completion?(true)
            
        }
        
    }
    
    
    /// Pulls the file-data from given url
    /// - Parameters:
    ///   - url: URL for the file
    ///   - completion: Returns boolean that indicates success or failure. Data is nil if fetch failed.
    static func pullData(url: URL, completion: ((Bool, Data?) -> Void)? = nil) {
        
        guard FileManager.default.fileExists(atPath: url.path) else {
            Logger.main.debug("File \(url.path) does not exist")
            completion?(false, nil)
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            completion?(true, data)
        } catch {
            Logger.main.error("Could not read node from file: \(url.path)")
            completion?(false, nil)
        }
        
    }
    
    
    /// Writing Node to file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: ((Bool) -> Void)? = nil) {
        
        serializationQueue.async {
            
            guard let nodeCodable = self.codable, let url = self.url else {
                completion?(false)
                return
            }
            
            do {
                let encoder = PropertyListEncoder()
                let data = try encoder.encode(nodeCodable)
                try data.write(to: url)
            } catch {
                Logger.main.error("Could not write NodeCodable to file: \(error.localizedDescription)")
                completion?(false)
            }
            
            guard var cloudURL = Settings.getCloudPath() else {
                completion?(true)
                return
            }
            var localURL = Settings.getLocalPath()
            
            /// - Checks if this file is relevant to our iCloud | Local Storage discussion
            if url.deletingPathExtension().deletingLastPathComponent() != cloudURL && url.deletingPathExtension().deletingLastPathComponent() != localURL {
                completion?(true)
                return
            }
            
            cloudURL = cloudURL.appendingPathComponent(self.name!).appendingPathExtension("jot")
            localURL = localURL.appendingPathComponent(self.name!).appendingPathExtension("jot")
                        
            let sourceURL = settings.codable.usesCloud ? localURL : cloudURL
            let destinationURL = settings.codable.usesCloud ? cloudURL : localURL
            
            /// - If the destinationURL already exists, there is no need to run the setUbiquitous method
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                completion?(true)
                return
            }
            
            do {
                try FileManager.default.setUbiquitous(settings.codable.usesCloud, itemAt: sourceURL, destinationURL: destinationURL)
            } catch {
                Logger.main.error("\(error.localizedDescription)")
            }
            
            completion?(true)
        }
        
    }
    
    
    /// Updates meta-data such as the thumbnail of the Node
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func updateMeta(completion: ((Bool) -> Void)? = nil) {
        
        thumbnailGenerator.execute(for: self) { [self] (success, image) in
            thumbnail = image
            
            if let collector = collector {
                collector.didUpdate()
            }
            
            completion?(success)
        }
        
    }
    
    
    /// Moves drawing to Node. Calls update to generate thumbnail
    /// - Parameter drawing: Given PKDrawing
    func setDrawing(drawing: PKDrawing) {
        
        codable?.drawing = drawing
        codable?.lastModified = NSDate().timeIntervalSince1970
        
        updateMeta()
        push()
        
    }
 
    
    
    // MARK: - Filesystem methods
    
    /// Renames the Nodes name
    /// IMPORTANT: - name = name.jot; name.jot = name
    /// - Parameters:
    ///   - name: New name of the Node
    ///   - completion: Returns a boolean that indicates success or failure
    func rename(to name: String, completion: ((Bool) -> Void)? = nil) {
        
        guard let originURL = url, let destinationURL = url?.deletingLastPathComponent().appendingPathComponent(name).appendingPathExtension("jot") else {
            completion?(false)
            return
        }
        
        do {
            try FileManager.default.moveItem(at: originURL, to: destinationURL)
        } catch {
            Logger.main.error("\(error.localizedDescription)")
            completion?(false)
        }
        
        self.url = destinationURL
        self.name = name
        
        self.collector?.didUpdate()
        
        completion?(true)
        
    }
    
    
    /// Clones the Node's content. Name will be updated automatically with suffix 'copy'
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func duplicate(completion: ((Bool) -> Void)? = nil) {
        
        guard let name = self.name, let url = self.url, let collector = self.collector else {
            completion?(false)
            return
        }
        
        let croppedURL = url.deletingPathExtension().deletingLastPathComponent()
        
        let updatedName = NodeCollector.computeCopyName(baseName: name, path: croppedURL)
        
        let node = Node(url: croppedURL.appendingPathComponent(updatedName).appendingPathExtension("jot"))
        node.setDrawing(drawing: self.codable!.drawing)
        node.pull { (success) in
            if success {
                collector.nodes.append(node)
                completion?(true)
                return
            }
            completion?(false)
        }
        
    }
    
    
    /// Deletes the Node from the filesystem
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func delete(completion: ((Bool) -> Void)? = nil) {
        
        guard let url = url else {
            completion?(false)
            return
        }
        
        guard let collector = collector, let index = collector.nodes.firstIndex(of: self) else {
            completion?(false)
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Logger.main.error("Could not delete Node at \(url). Reason: \(error.localizedDescription)")
            completion?(false)
        }

        collector.nodes.remove(at: index)
        completion?(true)

    }
    
}
