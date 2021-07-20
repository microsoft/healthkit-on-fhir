//
//  LandingPageViewController.swift
//  researchKitOnFhir
//
//  Created by admin on 7/14/21.
//

import UIKit
import SMART
import ResearchKit

class LandingScreenViewController: UIViewController {

    @IBOutlet var surveyListButton: UIButton!
    var smartClient: Client?
    
    var didAttemptAuthentication = false
    
    @IBOutlet weak var defaultPatientButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultPatientButton.isHidden = true
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        smartClient = appDelegate?.smartClient
        
        if (!didAttemptAuthentication) {
            didAttemptAuthentication = true
            smartClient?.authorize(callback: { (patient, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        print("Connection to server complete")
                        self.defaultPatientButton.isHidden = false
                    } else {
                        print(error)
                    }
                }
            })
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBSegueAction func defaultUser(_ coder: NSCoder) -> SurveyListViewController? {
        
        var surveyList = SurveyListViewController(coder: coder)
       
        return surveyList
    }
    
    }
    


