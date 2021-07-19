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
    
    static let buttonGap = 5
    static let buttonHeight = 70
    // TODO: find way to dynamically set
    static let startingButtonTopCoordinate = 95
    static var buttonTopCoordinate = startingButtonTopCoordinate
    
    
    static var questionnaireList = [QuestionnaireType]()
    
    /*
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
     */
    
    @IBOutlet weak var backButton: UINavigationItem!
    
    
    override func loadView() {
        super.loadView()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        smartClient = appDelegate?.smartClient
        
        if (!didAttemptAuthentication) {
            didAttemptAuthentication = true
            smartClient?.authorize(callback: { (patient, error) in
                DispatchQueue.main.async {
                    print("ERROR - SurveyListViewController 45: \(error)")
                    print("HELLO")
                    // self.surveyButton.isHidden = false
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            var tagNum = 0
        
            for questionnaireTypeItem in SurveyListViewController.questionnaireList {
                if !questionnaireTypeItem.questionnaireComplete {
                    let questionnaireTitle = (questionnaireTypeItem.FHIRquestionnaire.title?.string)!
                    self.view.addSubview(self.makeNewButton(text: questionnaireTitle, newTag: tagNum))
                    SurveyListViewController.buttonTopCoordinate += SurveyListViewController.buttonHeight + SurveyListViewController.buttonGap
                }
                tagNum += 1
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func surveyClicked(_ sender: UIButton) {
        
        let questionnaire = SurveyListViewController.questionnaireList[sender.tag]
        print(questionnaire.FHIRquestionnaire.title?.string)
        /*
        
        let questionnaireConverter = FHIRtoRKConverter()
        
        let ed = ExternalStoreDelegate()
        
        ed.getTasksFromServer { (taskId, error) in
            
            let questionnaireId = taskParser.singleTask.basedOn![0].reference!.string
            taskParser.questionnaireIds = questionnaireId
            
            questionnaireConverter.extractSteps(reference: "dummy") { (title, steps, error) in
                
                let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: FHIRtoRKConverter.ORKStepQuestionnaire)
                DispatchQueue.main.async {
                    let taskViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
                    taskViewController.delegate = self
                    self.present(taskViewController, animated: true, completion: nil)
                }
            }
        }
         */
        
        
        
    }
    
    func makeNewButton(text: String, newTag: Int) -> UIButton {
        let newButton = UIButton(type: UIButton.ButtonType.system)
        let buttonWidth = Int(view.frame.size.width)-(SurveyListViewController.buttonGap*2)
        
        newButton.setTitle(text, for: .normal)
        newButton.setTitleColor(UIColor.black, for: .normal)
        newButton.frame(forAlignmentRect: CGRect(x: SurveyListViewController.buttonGap, y: SurveyListViewController.buttonTopCoordinate, width: buttonWidth, height: SurveyListViewController.buttonHeight))
        newButton.backgroundColor = UIColor(cgColor: CGColor(red: 0.4, green: 0, blue: 0.6, alpha: 0.5))
        newButton.bounds = CGRect(x: 0, y: 0, width: buttonWidth, height: SurveyListViewController.buttonHeight)
        newButton.center = CGPoint(x: Int(view.frame.size.width)/2, y: Int(SurveyListViewController.buttonTopCoordinate + SurveyListViewController.buttonHeight/2))
        newButton.layer.borderWidth = 2
        newButton.layer.borderColor = CGColor(red: 0.4, green: 0, blue: 0.6, alpha: 1)
        newButton.tag = newTag
        newButton.addTarget(self, action: #selector(surveyClicked), for: .touchUpInside)
        
        return newButton
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
            SurveyListViewController.buttonTopCoordinate = SurveyListViewController.startingButtonTopCoordinate
            print("REASON: discarded")
        case .failed:
            taskViewController.dismiss(animated: true, completion: nil)
            print("REASON: failed")
        @unknown default:
            print("REASON: unknown default")
        }
    }
}
    
    
  
