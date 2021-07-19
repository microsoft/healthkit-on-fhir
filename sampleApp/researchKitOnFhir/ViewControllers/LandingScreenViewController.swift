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
                    print("ERROR - SurveyListViewController 45: \(error)")
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
            
            print("QUESTIONNAIRE IDS: \(taskParser.questionnaireIdList)")
            
            let questionnaireId = taskParser.singleTask.basedOn![0].reference!.string
            taskParser.questionnaireIds = questionnaireId
            
            for questionnaireId in taskParser.questionnaireIdList {
                
                questionnaireConverter.extractSteps(reference: questionnaireId) { (title, steps, error) in
                    
                    let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: FHIRtoRKConverter.ORKStepQuestionnaire)
                    // print("TITLE:  \(title)")
                    DispatchQueue.main.async {
                    }
                }
            }
            
        }
        
        return surveyList
    }
    
    @IBSegueAction func homeToQuestionnaireList(_ coder: NSCoder) -> SurveyListViewController? {
        
        var newSurveyList = SurveyListViewController()
        
        let externalSD = ExternalStoreDelegate()
        
        externalSD.getTasksFromServer() { taskId, error in
            print("getQuestionnairesFromTask")
            print(taskId)
        }
        
        // load in tasks
        // iterate through the tasks to find the ones assigned to samplePatient
        // load all of those Questionnaires into an array of Questionnaires (including processing them)
        
        return newSurveyList
    }
    
    }
    
    
    
  
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


