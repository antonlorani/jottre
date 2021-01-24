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
            UIView.animate(withDuration: 0.5) {
                self.infoTextView.alpha = self.hasDocuments ? 0 : 1
                self.collectionView.alpha = self.hasDocuments ? 1 : 0
            }
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
            textView.text = Downloader.isCloudEnabled ? textView.text : UIDevice.isLimited() ? NSLocalizedString("Enable iCloud to view files created with 'Jottre for iPad'", comment: "") : NSLocalizedString("Enable iCloud to unlock the full potential of Jottre", comment: "")
            textView.textAlignment = .center
            textView.isScrollEnabled = false
            textView.backgroundColor = .clear
            textView.alpha = 0
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
            collectionView.backgroundColor = .clear
            collectionView.register(NodeCell.self, forCellWithReuseIdentifier: "nodeCell")
            collectionView.alpha = 0
            
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
        
        navigationItem.title = "Jottre"
        
        view.backgroundColor = .systemBackground
        
        if !UIDevice.isLimited() {
        
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: NavigationButton(title: NSLocalizedString("Add note", comment: ""), target: self, action: #selector(createNode)))
        
        }
        
        if !Downloader.isCloudEnabled {
            presentInfoAlert()
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
        
        settings.addObserver(self)
        
    }
    
    
    @objc func createNode() {
        
        let alertTitle = NSLocalizedString("New note", comment: "")
        let alertMessage = NSLocalizedString("Enter a name for the new note", comment: "")
        
        let noteName = NSLocalizedString("My note", comment: "")
        
        let alertPrimaryActionTitle = NSLocalizedString("Create", comment: "")
        let alertCancelTitle = NSLocalizedString("Cancel", comment: "")
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = noteName
        }
        
        alertController.addAction(UIAlertAction(title: alertPrimaryActionTitle, style: .default, handler: { (action) in
            
            guard let textFields = alertController.textFields, var name = textFields[0].text else {
                return
            }
            name = name == "" ? noteName : name
            
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
        
        alertController.addAction(UIAlertAction(title: alertCancelTitle, style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    func presentInfoAlert() {
        
        let alertTitle = NSLocalizedString("iCloud disabled", comment: "")
        let alertMessage = NSLocalizedString("While iCloud is disabled, you can only open files that are locally on this device.", comment: "")

        let alertPrimaryActionTitle = NSLocalizedString("How to enable iCloud", comment: "")
        let supportURL = NSLocalizedString("https://support.apple.com/en-us/HT208681", comment: "URL for iCloud setup")

        let alertCancelTitle = NSLocalizedString("Cancel", comment: "")
        
        
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: alertPrimaryActionTitle, style: .default, handler: { (action) in
            UIApplication.shared.open(URL(string: supportURL)!, options: [:], completionHandler: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: alertCancelTitle, style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    @objc func presentSettings() {
        
        let settingsController = SettingsViewController()
        
        let settingsNavigationController = SettingsNavigationViewController(rootViewController: settingsController)
                        
        present(settingsNavigationController, animated: true, completion: nil)
                        
    }
    
}
