//
//  NodeCollector.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit

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
        completion?(false)
    }
    
    
    /// Pulls a specific node from url.
    /// This node will be added to the NodeCollector
    /// - Parameters:
    ///   - url: Should point to a .jot file on the users file-system
    ///   - completion: Returns a boolean that indicates success or failure
    func pullNode(url: URL, completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    /// Force pulls all the Nodes to the file-system
    /// - Parameter completion: Returns a boolean that indicates success or failure
    func push(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    
    /// Updates the meta-data for each Node in this object
    func update() {
        nodes.forEach({ $0.updateMeta() })
    }
    
    
    /// Sends a message to each observer, that there happened changes inside this object.
    fileprivate func didUpdate() {
        
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
    
}
