//
//  ViewController.swift
//  sampleApp
//
//  Created by admin on 6/22/21.
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
                print(error)
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
    }
    
    @IBAction func consentTapped(sender : AnyObject) {
        let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }
    
    @IBAction func surveyClicked(sender : AnyObject) {
        let questionnaireConverter = QuestionnaireConverter()
        questionnaireConverter.extractSteps { (title, steps, error) in

            let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: QuestionnaireConverter.ORKStepQuestionnaire)
            DispatchQueue.main.async {
                let taskViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
                taskViewController.delegate = self
                self.present(taskViewController, animated: true, completion: nil)
            }
        }
    }
}

extension ViewController: ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch (reason) {
        case .completed:
            
                let questionnaireConverter = QuestionnaireConverter()
                
                let FHIRQuestionnaireResponse: QuestionnaireResponse = questionnaireConverter.RKQuestionResponseToFHIR(results: taskViewController)
            
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let smartClient = appDelegate?.smartClient
            
                // Post the Device to the FHIR server
            FHIRQuestionnaireResponse.create(smartClient?.server as! FHIRServer) { (error) in
                    //Ensure there is no error
                    guard error == nil else {
                        print(error)
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

