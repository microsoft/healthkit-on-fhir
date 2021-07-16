//
//  SurveyListViewController.swift
//  researchKitOnFhir
//
//  Created by admin on 7/14/21.
//

import UIKit
import ResearchKit
import SMART

class SurveyListViewController: UIViewController {
   
    var smartClient: Client?
    var didAttemptAuthentication = false
    @IBOutlet var surveyButton: UIButton!
    
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
                DispatchQueue.main.async {
                    print("ERROR - SurveyListViewController 45: \(error)")
                    // self.surveyButton.isHidden = false
                }
            })
        }
        
    }
    
    @IBAction func surveyClicked(_ sender: UIButton) {
        let questionnaireConverter = FHIRtoRKConverter()
        
        let ed = ExternalStoreDelegate()
        
        ed.getTasksFromServer { (taskId, error) in
            
            let questionnaireId = taskParser.singleTask.basedOn![0].reference!.string
            taskParser.questionnaireIds = questionnaireId
            
            questionnaireConverter.extractSteps { (title, steps, error) in
                
                let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: FHIRtoRKConverter.ORKStepQuestionnaire)
                DispatchQueue.main.async {
                    let taskViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
                    taskViewController.delegate = self
                    self.present(taskViewController, animated: true, completion: nil)
                }
            }
        }
        
    }
}

extension SurveyListViewController: ORKTaskViewControllerDelegate  {
    
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
                    print("ERROR - SurveyListViewController 85: \(error)")
                    return
                }
            }
            
            taskViewController.dismiss(animated: true, completion: nil)
            
        case .saved:
            print("REASON: saved")
        case .discarded:
            taskViewController.dismiss(animated: true, completion: nil)
            print("REASON: discarded")
        case .failed:
            taskViewController.dismiss(animated: true, completion: nil)
            print("REASON: failed")
        @unknown default:
            print("REASON: unknown default")
        }
    }
}
    
    
  
