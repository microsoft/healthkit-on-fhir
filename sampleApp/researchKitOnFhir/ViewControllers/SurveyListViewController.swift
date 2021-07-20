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
    
    // let scrollView = UIScrollView()
    // let contentView = UIView()
    
    let tableView = UITableView()
    
    static let buttonGap = 5
    static let buttonHeight = 70
    // TODO: find way to dynamically set
    static let startingButtonTopCoordinate = 95
    static var buttonTopCoordinate = startingButtonTopCoordinate
    
    var buttonList = [Int:String]()
    
    static var questionnaireList = [QuestionnaireType]()
    
    @IBOutlet weak var backButton: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionnaireConverter = FHIRtoRKConverter()
        
        let ed = ExternalStoreDelegate()
        
        DispatchQueue.main.async {
            self.view.reloadInputViews()
        }
        
        SurveyListViewController.questionnaireList.removeAll()
        SurveyListViewController.buttonTopCoordinate = SurveyListViewController.startingButtonTopCoordinate
        
        // setupScrollView()
        
        ed.getTasksFromServer { (taskId, error) in
            
            var tagNum = 0
            
            for (questionnaireId,complete) in taskParser.questionnaireIdList {
                print("QUESTIONNAIREID: \(questionnaireId)")
                questionnaireConverter.extractSteps(reference: questionnaireId, complete: complete) { (questionnaire, completed, error) in
                    
                    let questionnaireTitle = (questionnaire?.FHIRquestionnaire.title?.string)!
                    
                    SurveyListViewController.questionnaireList.append(QuestionnaireType(questionnaire: questionnaire!.FHIRquestionnaire, complete: questionnaire!.questionnaireComplete))
                    
                    DispatchQueue.main.async {
                        
                        if !questionnaire!.questionnaireComplete {
                           
                                self.view.addSubview(self.makeNewButton(text: questionnaireTitle, newTag: tagNum, complete: false))
                                self.surveyListLoadingIndicator.isHidden = true
                                
                                tagNum += 1
                              
                        } else {
                            
                            self.buttonList[tagNum] = questionnaireTitle
                            tagNum += 1
                            
                        }
                        
                        if tagNum == taskParser.questionnaireIds.count {
                            for (buttonTag,buttonTitle) in self.buttonList {
                                self.view.addSubview(self.makeNewButton(text: buttonTitle, newTag: buttonTag, complete: true))
                            }
                        }
                        
                    }
                }
            }
            
            /*
            DispatchQueue.main.async {
                var num = 1
                while num < 10 {
                    self.view.addSubview(self.makeNewButton(text: "Testing \(num)", newTag: 1))
                    num += 1
                    SurveyListViewController.buttonTopCoordinate += SurveyListViewController.buttonHeight + SurveyListViewController.buttonGap
                }
            }
            */
        }
    }
    
    /*
    func setupTableView () {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    */
    
    /*
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        scrollView.isScrollEnabled = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        scrollView.contentSize = contentView.frame.size
    }
    */
    
    @IBOutlet weak var surveyListLoadingIndicator: UIActivityIndicatorView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    @IBAction func surveyClicked(_ sender: UIButton) {
        
        let fhirToRk = FHIRtoRKConverter()
        let questionnaire = SurveyListViewController.questionnaireList[sender.tag]
        
        let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: fhirToRk.getORKStepsFromQuestionnaire(questionnaire: questionnaire.FHIRquestionnaire))
        
        let taskViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
        taskViewController.delegate = self
        FHIRtoRKConverter.currentIndex = sender.tag
        self.present(taskViewController, animated: true, completion: nil)
    }
    
    func makeNewButton(text: String, newTag: Int, complete: Bool) -> UIButton {
        let newButton = UIButton(type: UIButton.ButtonType.system)
        let buttonWidth = Int(view.frame.size.width)-(SurveyListViewController.buttonGap*2)
        
        newButton.setTitle(text, for: .normal)
        
        newButton.frame(forAlignmentRect: CGRect(x: SurveyListViewController.buttonGap, y: SurveyListViewController.buttonTopCoordinate, width: buttonWidth, height: SurveyListViewController.buttonHeight))
        
        if complete {
            newButton.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.5))
            newButton.setTitleColor(UIColor.darkGray, for: .normal)
        } else {
            newButton.backgroundColor = UIColor(cgColor: CGColor(red: 0.4, green: 0, blue: 0.6, alpha: 0.5))
            newButton.setTitleColor(UIColor.black, for: .normal)
        }
        
        newButton.bounds = CGRect(x: 0, y: 0, width: buttonWidth, height: SurveyListViewController.buttonHeight)
        newButton.center = CGPoint(x: Int(view.frame.size.width)/2, y: Int(SurveyListViewController.buttonTopCoordinate + SurveyListViewController.buttonHeight/2))
        
        newButton.layer.borderWidth = 2
        newButton.layer.borderColor = CGColor(red: 0.4, green: 0, blue: 0.6, alpha: 1)
        
        newButton.tag = newTag
        
        newButton.addTarget(self, action: #selector(surveyClicked), for: .touchUpInside)
        
        SurveyListViewController.buttonTopCoordinate += SurveyListViewController.buttonHeight + SurveyListViewController.buttonGap
        
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
            
            SurveyListViewController.questionnaireList[FHIRtoRKConverter.currentIndex].questionnaireComplete = true
            
            
            
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


    
    
  
