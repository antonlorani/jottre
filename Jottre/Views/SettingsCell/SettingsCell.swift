//
//  SettingsCell.swift
//  Jottre
//
//  Created by Anton Lorani on 17.01.21.
//

import UIKit

class SettingsCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var title: String = "Label" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var image: UIImage = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    
    
    
    // MARK: - Subviews
    
    var titleLabel: UILabel = {
        let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "Label"
            label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = UIColor.gray
        return imageView
    }()
    
    
    
    // MARK: - Override methods
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupViews()

    }
    
    
    
    // MARK: - Methods
    
    func setupViews() {
        
        backgroundColor = .systemGray5

        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        addSubview(titleLabel)
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        
        addSubview(imageView)
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 35).isActive = true

    }
    
}

