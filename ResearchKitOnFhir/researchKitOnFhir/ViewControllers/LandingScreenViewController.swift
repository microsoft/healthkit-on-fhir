//
//  LandingScreenViewController.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import UIKit
import SMART

class LandingScreenViewController: ViewControllerBase {
    
    @IBOutlet weak var configMessageLabel: UILabel!
    
    var didAttemptAuthentication = false
    
    @IBOutlet weak var authenticatedPatientButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if targetEnvironment(simulator)
            configMessageLabel.text = "Drag the Config.json file onto the Simulator screen to begin."
        #else
            configMessageLabel.text = "Tap on your configuration file and choose this application to open it."
        #endif
        
        self.authenticatedPatientButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the loading indicator
        loadLandingScreenView()
    }
    
    func loadLandingScreenView () {
        updateViewState(isLoading: false)
        
        if !didAttemptAuthentication {
            authenticate();
        }
    }
    
    @objc public override func servicesDidUpdate() {
        super.servicesDidUpdate()
        updateViewState(isLoading: false)
        authenticate()
    }
    
    public func updateViewState(isLoading: Bool, message: String? = nil) {
        DispatchQueue.main.async {
            self.configMessageLabel.isHidden = self.smartClient != nil
            
        }
    }
    
    private func authenticate() {
        didAttemptAuthentication = true
        
        updateViewState(isLoading: smartClient != nil)
        
        // Authorize the application using the SMART on FHIR Framework.
        smartClient?.authorize(callback: { (patient, error) in
            if let error = error {
                print(error)
                
                // An error occurred, reset the client to force the authentication UI flow.
                self.smartClient?.reset()
                self.updateViewState(isLoading: false)
                
                return
            }
            
            // display navigation button to authenticated patient questionnaire list once authentication is complete
            DispatchQueue.main.async {
                self.authenticatedPatientButton.isHidden = false
            }
        })
    }
    
    
    @IBSegueAction func authenticatedUserSegue(_ coder: NSCoder) -> SurveyListViewController? {
        return SurveyListViewController(coder: coder)
    }
    
}



