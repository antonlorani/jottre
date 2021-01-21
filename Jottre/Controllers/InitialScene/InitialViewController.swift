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
    
    var initialLoad: Bool = true
    
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
            textView.text = UIDevice.isLimited() ? NSLocalizedString("Documents created with the 'Jottre for iPad' App can be viewed here.", comment: "") : NSLocalizedString("No documents available yet. Click 'Add note' to create a new file.", comment: "")
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

    
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupDelegates()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        nodeCollector.traitCollection = traitCollection
    
    }
    
    
    
    // MARK: - Methods
    
    private func setupViews() {
        
        view.backgroundColor = .white
        navigationItem.title = "Jottre"
        
        if !UIDevice.isLimited() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: NavigationButton(title: NSLocalizedString("Add note", comment: ""), target: self, action: #selector(createNode)))
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: SettingsButton(target: self, action: #selector(presentSettings)))
        
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
        
        nodeCollector.traitCollection = traitCollection
        
        nodeCollector.addObserver(self)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        settings.addObserver(self)
        
    }
    
    
    @objc func createNode() {
        
        let localizedAlertTitle = NSLocalizedString("New note", comment: "")
        
        let localizedAlertMessage = NSLocalizedString("Enter a name for the new note", comment: "")
        
        let localizedNoteName = NSLocalizedString("My note", comment: "")
        
        let localizedPrimaryActionTitle = NSLocalizedString("Create", comment: "")
        
        let localizedSecondaryActionTitle = NSLocalizedString("Cancel", comment: "")
        
        
        let alertController = UIAlertController(title: localizedAlertTitle, message: localizedAlertMessage, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = localizedNoteName
        }
        
        alertController.addAction(UIAlertAction(title: localizedPrimaryActionTitle, style: .default, handler: { (action) in
            
            guard let textFields = alertController.textFields, var name = textFields[0].text else {
                return
            }
            name = name == "" ? localizedNoteName : name
            
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
        
        alertController.addAction(UIAlertAction(title: localizedSecondaryActionTitle, style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @objc func presentSettings() {
        
        let settingsController = SettingsViewController()
        
        let settingsNavigationController = SettingsNavigationViewController(rootViewController: settingsController)
        
        settingsNavigationController.modalPresentationStyle = .formSheet
                
        present(settingsNavigationController, animated: true, completion: nil)
                        
    }
    
}
