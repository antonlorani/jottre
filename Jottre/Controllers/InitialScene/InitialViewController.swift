//
//  InitialViewController.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import os.log


class InitialViewController: UIViewController {
    
    // MARK: - Properties
    
    var nodeCollector: NodeCollector = NodeCollector()
    
    var hasDocuments: Bool = false {
        didSet {
            infoTextView.alpha = hasDocuments ? 0 : 1
        }
    }
    
    
    
    // MARK: - Subviews
    
    var infoTextView: UITextView = {
        let textView = UITextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.isEditable = false
            textView.isSelectable = false
            textView.font = UIFont.systemFont(ofSize: 25, weight: .regular)
            textView.textColor = UIColor.secondaryLabel
            textView.text = "No documents available yet. Click 'Add' to create a new file."
            textView.textAlignment = .center
            textView.isScrollEnabled = false
        return textView
    }()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: UIScreen.main.bounds.width >= (232 * 2 + 40) ? 232 : UIScreen.main.bounds.width - 40, height: 291)
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 20
            
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.backgroundColor = .systemBackground
            collectionView.register(NodeCell.self, forCellWithReuseIdentifier: "nodeCell")
            
        return collectionView
    }()

    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupDelegates()
        
    }
    
    
    
    // MARK: - Methods
    
    private func setupViews() {
        
        view.backgroundColor = .white
        navigationItem.title = "My notes"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: NavigationButton(title: "Add note", target: self, action: #selector(createNode)))
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        view.addSubview(infoTextView)
        infoTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        infoTextView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        infoTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true

    }
    
    
    private func setupDelegates() {
        
        nodeCollector.addObserver(self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    
    @objc func createNode() {
        
        let alertController = UIAlertController(title: "New note", message: "Enter a name for your new note", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "My note"
        }
        
        alertController.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            
            guard let textFields = alertController.textFields, var name = textFields[0].text else {
                return
            }
            name = name == "" ? "My note" : name
            
            self.nodeCollector.createNode(name: name) { (success, node) in

                guard let node = node else {
                    return
                }
                
                self.nodeCollector.disableObservers()
                self.nodeCollector.nodes.append(node)
                
                DispatchQueue.main.async {
                    
                    self.collectionView.performBatchUpdates {
                        let indexPath = IndexPath(item: self.nodeCollector.nodes.count - 1, section: 0)
                        self.collectionView.insertItems(at: [indexPath])
                    } completion: { (success) in
                        self.nodeCollector.enableObservers()
                    }
                    
                }
                                
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}
