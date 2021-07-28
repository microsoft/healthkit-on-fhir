//
//  LoadingView.swift
//  researchKitOnFhir
//
//  Created by admin on 7/26/21.
//

import Foundation
import UIKit

class LoadingView : UIView {
    
    @IBOutlet var messageLabel: UILabel!
    
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


