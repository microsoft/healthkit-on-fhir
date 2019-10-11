//
//  ViewControllerBase.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import SMART

class ViewControllerBase : UIViewController {
    
    @IBOutlet var contentViews: [UIView]!
    
    public var smartClient: Client?
    
    private let loadingView = LoadingView.shared
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(servicesDidUpdate), name: AppDelegate.servicesDidUpdateNotification, object: nil)
        
        // The SMART Client was created during the app launch, use the same instance here
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        smartClient = appDelegate?.smartClient
    }
    
    public func showErrorAlert(error: Error) {
        print(error)
        self.updateViewState(isLoading: false)
    }
    
    public func navigate(segueIdentifier: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segueIdentifier, sender: nil)
        }
    }
    
    public func updateViewState(isLoading: Bool, message: String? = nil) {
        DispatchQueue.main.async {
            for view in self.contentViews {
                view.isUserInteractionEnabled = !isLoading
                view.alpha = isLoading ? 0.25 : 1.0
            }
            
            if isLoading {
                self.loadingView.show(in: self.view, message: message)
            } else {
                self.loadingView.hide()
            }
        }
    }
    
    @objc public func servicesDidUpdate() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        smartClient = appDelegate?.smartClient
    }
    
    @IBAction func signOut(sender: UIButton) {
        smartClient?.reset()
        navigationController?.popToRootViewController(animated: true)
    }
}
