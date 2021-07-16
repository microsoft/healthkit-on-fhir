//
//  LandingPageViewController.swift
//  researchKitOnFhir
//
//  Created by admin on 7/14/21.
//

import UIKit
import SMART

class LandingScreenViewController: UIViewController {

    @IBOutlet var surveyListButton: UIButton!
    
    var didAttemptAuthentication = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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


