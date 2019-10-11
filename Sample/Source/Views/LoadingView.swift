//
//  LoadingView.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit

class LoadingView : UIView {
    
    @IBOutlet var messageLabel: UILabel!
    
    static let shared: LoadingView = {
        if let view = Bundle(for: LoadingView.self).loadNibNamed("LoadingView", owner: self, options: nil)?.first as? LoadingView {
            return view
        }
        
        return LoadingView()
    }()
    
    private var defaultMessage = "Loading..."
    
    public func show(in view: UIView, message: String? = nil) {
        messageLabel.text = message ?? defaultMessage
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                           NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)]
        
        view.addConstraints(constraints)
        NSLayoutConstraint.activate(constraints)
    }
    
    public func hide() {
        self.removeFromSuperview()
    }
}
