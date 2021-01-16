//
//  NodeCollector.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import os.log

protocol NodeCollectorObserver {
    func nodeCollectorDidChange()
}

class NodeCollector {
    
    // MARK: - Properties
    
    private var observers: [NodeCollectorObserver] = []
    
    var observersEnabledValue: Bool = true
    
    var observersEnabled: Bool {
        return observersEnabledValue
    }
    
    
    static var path: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var nodes: [Node] = [] {
        didSet {
            didUpdate()
        }
    }
    
    
    
    // MARK: - Init
    
    /// Initializes the NodeCollector object and automatically pulls Nodes from the default container-path
    init() {
        pull()
    }
    
    

    // MARK: - Methods
    
    /// Loads the nodes from default path
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func pull(completion: ((Bool) -> Void)? = nil) {
        let files = try! FileManager.default.contentsOfDirectory(atPath: NodeCollector.path.path)
        
        files.forEach { (name) in
            let url = NodeCollector.path.appendingPathComponent(name)
            self.pullNode(url: url)
        }
        
        completion?(true)
    }
    
    
    /// Pulls a specific node from url.
    /// This node will be added to the NodeCollector
    /// - Parameters:
    ///   - url: Should point to a .jot file on the users file-system
    ///   - completion: Returns a boolean that indicates success or failure
    func pullNode(url: URL, completion: ((Bool) -> Void)? = nil) {
        
        let node = Node(url: url)
            node.collector = self
            node.pull { (success) in
                if success {
                    self.nodes.append(node)
                }
                completion?(success)
            }
        
    }
    
    
    /// Force pulls all the Nodes to the file-system
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: ((Bool) -> Void)? = nil) {
        
        nodes.forEach({ $0.push() })
        completion?(true)
        
    }
    
    
    /// Creates a new Node for given name
    /// - Parameter name: This will be the name and filename (without suffix .jot) of the Node
    /// - Parameter completion: Returns a boolean that indicates success or failure and the hopefully created node
    func createNode(name: String, completion: ((_ success: Bool, _ node: Node?) -> Void)? = nil) {
        
        let name = NodeCollector.computeCopyName(baseName: name, path: NodeCollector.path)
        let nodePath = NodeCollector.path.appendingPathComponent(name).appendingPathExtension("jot")
        
        let node = Node(url: nodePath)
            node.collector = self
            node.push { (success) in
                completion?(success, success ? node : nil)
            }
        
    }
    
    
    /// Updates the meta-data for each Node in this object
    func update() {
        nodes.forEach({ $0.updateMeta() })
    }
    
    
    /// Sends a message to each observer, that there happened changes inside this object.
    func didUpdate() {

        if !observersEnabled { return }
        
        DispatchQueue.main.async {
            self.observers.forEach({ $0.nodeCollectorDidChange() })
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
    
    
    /// Adds a new observer to this class ;)
    func addObserver(_ observer: NodeCollectorObserver) {
        observers.append(observer)
    }
    
    
    
    // MARK: - Static methods
    
    /// Generates a name and will modify it if this name already exists in a given directory
    /// - Parameter baseName: The target name
    /// - Parameter path: The path where this file is stored
    /// - Returns: The validated name (If name already exists this method adds the suffix ' copy' to the baseName)
    static func computeCopyName(baseName: String, path: URL) -> String {
        var newName: String = baseName
        var currentPath: URL = path.appendingPathComponent(newName).appendingPathExtension("jot")
        
        while true {
            if FileManager.default.fileExists(atPath: currentPath.path) {
                newName = "\(newName) (copy)"
                currentPath = currentPath.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension("jot")
                continue
            }
            break
        }
        
        return newName
    }
    
}
