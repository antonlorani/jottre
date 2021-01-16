//
//  Node.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import Foundation
import PencilKit
import os.log


/// A custom helper class that generates the thumbnails for a given Node
var thumbnailGenerator: ThumbnailGenerator = ThumbnailGenerator(size: CGSize(width: 200, height: 300))


/// The content of this struct will be serialized to a binary file
struct NodeCodable: Codable {
    
    var drawing: PKDrawing = PKDrawing()
    
}


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
    
    var thumbnail: UIImage?
    
    var nodeCodable: NodeCodable?
    
    var collector: NodeCollector?
    
    private var serializationQueue = DispatchQueue(label: "SerializationQueue", qos: .background)
    
    
    
    // MARK: - Init
    
    /// Initializer for a Node from a custom url
    /// - Parameter url: Should point to a .jot file on the users file-system
    init(url: URL) {
        super.init()
        
        setupValues(url: url, nodeCodable: NodeCodable())
        
    }
    
    
    /// Helper method for the initializer
    /// - Parameters:
    ///   - url: url passed via initializer
    ///   - nodeCodable: A valid NodeCodable object
    private func setupValues(url: URL, nodeCodable: NodeCodable) {
        self.url = url
        self.nodeCodable = nodeCodable
    }
    
    
    
    // MARK: - Methods
    
    /// Loading Node from file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func pull(completion: ((Bool) -> Void)? = nil) {
        completion?(true)
    }
    
    
    /// Writing Node to file
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: ((Bool) -> Void)? = nil) {
        completion?(true)
    }
    
    
    /// Updates meta-data such as the thumbnail of the Node
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func updateMeta(completion: ((Bool) -> Void)? = nil) {
        
        thumbnailGenerator.execute(for: self) { [self] (success, image) in
            self.thumbnail = image
            
            if let collector = self.collector {
                collector.didUpdate()
            }
            
            completion?(success)
            
        }
        
    }
    
    
    /// Moves drawing to Node. Calls update to generate thumbnail
    /// - Parameter drawing: Given PKDrawing
    func setDrawing(drawing: PKDrawing) {
        
        nodeCodable?.drawing = drawing
        updateMeta()
        
    }
 
    
    
    // MARK: - Filesystem methods
    
    /// Renames the Nodes name
    /// IMPORTANT: - name = name.jot; name.jot = name
    /// - Parameters:
    ///   - name: New name of the Node
    ///   - completion: Returns a boolean that indicates success or failure
    func rename(to name: String, completion: ((Bool) -> Void)? = nil) {
        completion?(true)
    }
    
    
    /// Clones the Node's content. Name will be updated automatically with suffix 'copy'
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func duplicate(completion: ((Bool) -> Void)? = nil) {
        completion?(true)
    }
    
    
    /// Deletes the Node from the filesystem
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func delete(completion: ((Bool) -> Void)? = nil) {
        completion?(true)
    }
    
}
