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
                    print("Connection to server complete")
                    // self.surveyButton.isHidden = false
                }
            })
        }
        
    }
    
    @IBSegueAction func defaultUser(_ coder: NSCoder) -> SurveyListViewController? {
        var surveyList = SurveyListViewController(coder: coder)
        
        let questionnaireConverter = FHIRtoRKConverter()
        
        let ed = ExternalStoreDelegate()
        
        ed.getTasksFromServer { (taskId, error) in
            
            let questionnaireId = taskParser.singleTask.basedOn![0].reference!.string
            taskParser.questionnaireIds = questionnaireId
            
            for questionnaireId in taskParser.questionnaireIdList {
                
                questionnaireConverter.extractSteps(reference: questionnaireId) { (title, steps, error) in
                    
                    let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: FHIRtoRKConverter.ORKStepQuestionnaire)
                    
                }
            }
            
        }
        
        return surveyList
    }
    
    }
    


