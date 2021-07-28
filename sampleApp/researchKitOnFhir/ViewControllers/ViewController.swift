//
//  ViewController.swift
//  sampleApp
//

import UIKit
import ResearchKit
import SMART

class ViewController: UIViewController {
    
    var smartClient: Client?
    var didAttemptAuthentication = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        smartClient = appDelegate?.smartClient
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if (!didAttemptAuthentication) {
            didAttemptAuthentication = true
            smartClient?.authorize(callback: { (patient, error) in
                print("ERROR - ViewController 31: \(error)")
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
}

extension ViewController: ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch (reason) {
        case .completed:
            
                let questionnaireConverter = RKtoFHIRConverter()
                
                let FHIRQuestionnaireResponse: QuestionnaireResponse = questionnaireConverter.RKQuestionResponseToFHIR(results: taskViewController)
            
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let smartClient = appDelegate?.smartClient
            
                // Post the Device to the FHIR server
            FHIRQuestionnaireResponse.create(smartClient?.server as! FHIRServer) { (error) in
                    //Ensure there is no error
                    guard error == nil else {
                        print("ERROR - SurveyListViewController 66: \(error)")
                        return
                    }
                }
            
            taskViewController.dismiss(animated: true, completion: nil)
            
        case .saved:
            print("REASON: saved")
        case .discarded:
            print("REASON: discarded")
        case .failed:
            print("REASON: failed")
        @unknown default:
            print("REASON: unknown default")
        }
}
}

