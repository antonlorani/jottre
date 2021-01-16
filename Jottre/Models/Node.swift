//
//  Node.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import PencilKit
import os.log

/// The content of this struct will be serialized to a binary file
struct NodeCodable: Codable {
    
    var drawing: PKDrawing = PKDrawing()
    
}

/// This class will manage the processes of a NodeCodable
/// This includes: encoding, decoding and basic file system related methods
class Node: NSObject {
    
    // MARK: - Properties
    
    var name: String? {
        didSet {
            guard let name = name else { return }
            url = NodeCollector.path.appendingPathComponent(name).appendingPathExtension("jot")
        }
    }
    
    var url: URL?
    
    var thumbnail: UIImage?
    
    var nodeCodable: NodeCodable?
    
    var collector: NodeCollector?
    
    private var serializationQueue = DispatchQueue(label: "SerializationQueue", qos: .background)
    
    
    
    // MARK: - Init
    
    /// Initializer for a Node from a custom url
    /// - Parameter url: Should point to a .jot file on the users file-system
    init(url: URL) {
        super.init()
        
        self.nodeCodable = NodeCodable()
        self.name = url.deletingPathExtension().lastPathComponent
        self.url = url
        
    }
    
    
    
    // MARK: - Methods
    
    /// Loading Node from file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func pull(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    /// Writing Node to file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    /// Updates meta-data such as the thumbnail of the Node
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func updateMeta(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
 
    
    
    // MARK: - Filesystem methods
    
    /// Renames the Nodes name
    /// IMPORTANT: - name = name.jot; name.jot = name
    /// - Parameters:
    ///   - name: New name of the Node
    ///   - completion: Returns a boolean that indicates success or failure
    func rename(to name: String, completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    /// Clones the Node's content. Name will be updated automatically with suffix 'copy'
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func duplicate(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    /// Deletes the Node from the filesystem
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func delete(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
}
