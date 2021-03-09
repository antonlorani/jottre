//
//  NodeExtensions.swift
//  Jottre
//
//  Created by Anton Lorani on 02.02.21.
//

import Foundation
import OSLog

extension Node {
    
    // MARK: - Methods
    
    /// Some helper methods so that we can use the methods below without the completion handler
    
    func push() { push { (_) in } }
    
    func prepareData() { prepareData { (_) in } }
    
    func pullData() { pullData { (_) in } }
    
    func pull() { pull { (_) in } }
    
    func pullHandler() { pullHandler { (_) in } }
        
}


extension Node {
    
    // MARK: - Filesystem methods
    
    /// Moves all files in root directoy to cloud or local path
    /// - Returns: Success or failure (true, false)
    func moveFilesIfNeeded() -> Bool {

        guard var cloudURL = Settings.getCloudPath(), let url = self.url else {
            return true
        }
        var localURL = Settings.getLocalPath()

        /// - Checks if this file is relevant to our iCloud | Local Storage discussion
        if url.deletingPathExtension().deletingLastPathComponent() != cloudURL && url.deletingPathExtension().deletingLastPathComponent() != localURL {
            return true
        }
            
        cloudURL = cloudURL.appendingPathComponent(self.name!).appendingPathExtension("jot")
        localURL = localURL.appendingPathComponent(self.name!).appendingPathExtension("jot")
                        
        let sourceURL = settings.codable.usesCloud ? localURL : cloudURL
        let destinationURL = settings.codable.usesCloud ? cloudURL : localURL
        

        /// - If the destinationURL already exists, there is no need to run the setUbiquitous method
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            return true
        }
            
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
        } catch {
            Logger.main.error("\(error.localizedDescription)")
        }
        
        return true
        
    }
    
    
    /// Checks wether there the node-file has changed after we read into memory
    /// - Parameter completion: Boolean value that indicates an inConflict or a notInConflict
    func inConflict(completion: ((Bool) -> Void)? = nil) {
        
        guard let url = self.url else {
            completion?(false)
            return
        }
        
        let cloudURL = url.deletingPathExtension().deletingLastPathComponent().appendingPathComponent(".\(self.name!)").appendingPathExtension("jot").appendingPathExtension("icloud")

        let tmpURL = FileManager.default.fileExists(atPath: cloudURL.path) ? cloudURL : url
        
        let tmpNode = Node(url: tmpURL)
        tmpNode.pull { (success) in

            if !success {
                completion?(false)
                return
            }
            
            if tmpNode.initialDataHash != self.initialDataHash {
                completion?(true)
            } else {
                completion?(false)
            }
            
        }
        
    }
    
    
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
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Logger.main.error("Could not delete Node at \(url). Reason: \(error.localizedDescription)")
            completion?(false)
        }
        
        completion?(true)

    }
    
}
