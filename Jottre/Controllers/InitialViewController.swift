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

    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
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
    
    @objc func createNode() {
        Logger.main.debug("Open request to create node")
    }
    
}
