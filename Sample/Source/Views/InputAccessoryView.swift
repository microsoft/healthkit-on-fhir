//
//  InputAccessoryView.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit

class InputAccessoryView : UIToolbar {
    @IBOutlet var button: UIBarButtonItem!
    
    public static func new(buttonTitle: String, target: AnyObject, selector: Selector) -> InputAccessoryView? {
        if let view = Bundle(for: InputAccessoryView.self).loadNibNamed("InputAccessoryView", owner: self, options: nil)?.first as? InputAccessoryView {
            view.button.title = buttonTitle
            view.button.target = target
            view.button.action = selector
            return view
        }
        
        return nil
    }
}
