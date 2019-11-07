//
//  LaunchViewController.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import SMART

class LaunchViewController : ViewControllerBase {
    @IBOutlet var configMessageLabel: UILabel!
    
    private var didAttemptAuthentication = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the configMessageLabel if the application is running in the simulator.
#if targetEnvironment(simulator)
        configMessageLabel.text = "Drag the Config.json file onto the Simulator screen to begin."
#endif
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the loading indicator
        updateViewState(isLoading: false)
        
        // Authenticate the user on app launch
        if !didAttemptAuthentication {
            authenticate();
        }
    }
    
    @IBAction func signIn(sender: UIButton) {
        authenticate()
    }
    
    @objc public override func servicesDidUpdate() {
        super.servicesDidUpdate()
        updateViewState(isLoading: false)
    }
    
    public override func updateViewState(isLoading: Bool, message: String? = nil) {
        super.updateViewState(isLoading: isLoading, message: message)
        DispatchQueue.main.async {
            self.configMessageLabel.isHidden = self.smartClient != nil
        }
    }
    
    private func authenticate() {
        didAttemptAuthentication = true
        
        // Authorize the application using the SMART on FHIR Framework.
        smartClient?.authorize(callback: { (patient, error) in
            if let error = error {
                print(error)
                
                // An error occurred, reset the client to force the authentication UI flow.
                self.smartClient?.reset()
                
                return
            }
            
            // The user is authenticated check if the logged in user has an associated patient resource.
            self.fetchPatient()
            
        })
    }
    
    private func fetchPatient() {
        updateViewState(isLoading: true)
        
        smartClient?.server.fetchAuthenticatedPatient(completion: { (patient, error) in
            guard error == nil else {
                // An error occurred, show an alert.
                self.showErrorAlert(error: error!)
                return
            }
            
            if patient != nil {
                // A Patient Resource exists continue to the Data Sync View
                self.navigate(segueIdentifier: "DataSyncSegue")
            } else {
                // No Patient Resource exists for this user, navigate to the Patient On-boarding View
                self.navigate(segueIdentifier: "PatientOnboardingSegue")
            }
        })
    }
}
