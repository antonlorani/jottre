//
//  LoadingView.swift
//  Jottre
//
//  Created by Anton Lorani on 21.01.21.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    // MARK: - Properties
    
    var isAnimating: Bool = false {
        didSet {
            isAnimating ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()

            UIView.animate(withDuration: 0.3) {
                self.transform = self.isAnimating ? .identity : CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.alpha = self.isAnimating ? 1 : 0
            }
            
        }
    }
    
    
    
    // MARK: - Subviews
    
    var blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
            view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()

    
    
    // MARK: - Override methods
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupViews()
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        layer.shadowColor = UIColor.label.cgColor
        backgroundColor = traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    
    }
    
    
    
    // MARK: - Methods
    
    func setupViews() {
        
        isAnimating = false
        
        translatesAutoresizingMaskIntoConstraints = false
        
        backgroundColor = .clear
        
        layer.cornerRadius = 15
        layer.masksToBounds = true
        
        addSubview(blurView)
        blurView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        blurView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        blurView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        addSubview(activityIndicatorView)
        activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        activityIndicatorView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
    }
    
}

