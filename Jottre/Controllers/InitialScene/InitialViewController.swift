//
//  InitialViewController.swift
//  Jottre
//
//  Created by Anton Lorani on 16.01.21.
//

import UIKit
import OSLog

class InitialViewController: UIViewController {
    
    // MARK: - Properties
    
    var initialLoad: Bool = true
    
    var nodeCollector: NodeCollector = NodeCollector()
    
    var hasDocumentsDelayFinished: Bool = false
    
    var hasDocuments: Bool = false {
        didSet {
            if !hasDocumentsDelayFinished { return }
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView.collectionViewLayout.invalidateLayout()
    
    }
    
    
    
    // MARK: - Methods
    
    private func setupViews() {
        
        navigationItem.title = "Jottre"
        
        view.backgroundColor = .systemBackground
        
        if !UIDevice.isLimited() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: NavigationTextButton(title: NSLocalizedString("Add note", comment: ""), target: self, action: #selector(createNode)))
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
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.dragDelegate = self
        
        nodeCollector.traitCollection = traitCollection
        nodeCollector.addObserver(self)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.hasDocumentsDelayFinished = true
            self.hasDocuments = !(!self.hasDocuments) /// A simple solution to reassign the value to call didSet
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(settingsDidChange(_:)), name: Settings.didUpdateNotificationName, object: nil)
        
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
            
            self.nodeCollector.createNode(name: name) { (node) in }
            
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
