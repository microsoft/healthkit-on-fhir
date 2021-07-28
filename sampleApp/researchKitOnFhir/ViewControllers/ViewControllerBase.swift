//
//  ViewControllerBase.swift
//  researchKitOnFhir
//
//  Created by admin on 7/26/21.
//

import Foundation
import UIKit
import SMART

class ViewControllerBase : UIViewController {
    
    @IBOutlet var contentViews: [UIView]!
    
    public var smartClient: Client?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(servicesDidUpdate), name: AppDelegate.servicesDidUpdateNotification, object: nil)
        
        // The SMART Client was created during the app launch, use the same instance here
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        smartClient = appDelegate?.smartClient
    }
    
    public func navigate(segueIdentifier: String) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segueIdentifier, sender: nil)
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
