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
    
    func pull(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    func pullNode(url: URL, completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    func push(completion: ((Bool) -> Void)? = nil) {
        completion?(false)
    }
    
    
    
    func update() {
        nodes.forEach({ $0.updateMeta() })
    }
    
    
    fileprivate func didUpdate() {
        
        if !observersEnabled { return }
        
        DispatchQueue.main.async {
            self.observers.forEach({ $0.nodeCollectorDidChange() })
        }
        
    }
    
    
    
    // MARK: - Observer methods
    
    func enableObservers() {
        observersEnabledValue = true
    }
    
    
    func disableObservers() {
        observersEnabledValue = false
    }
    
    
    func addObserver(_ observer: NodeCollectorObserver) {
        observers.append(observer)
    }
    
}
