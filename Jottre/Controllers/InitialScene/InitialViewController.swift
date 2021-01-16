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
        Logger.main.debug("Open request to create node")
    }
    
}
