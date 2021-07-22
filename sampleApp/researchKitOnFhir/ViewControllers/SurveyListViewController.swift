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
    
    let tableView = UITableView()
    
    @IBOutlet weak var contentView: UIView!
    
    static let buttonGap = 5
    static let buttonHeight = 70
    // TODO: find way to dynamically set
    static var startingButtonTopCoordinate = 0
    static var buttonTopCoordinate = startingButtonTopCoordinate
    
    var todoButtonList = [Int:String]()
    var completeButtonList = [Int: String]()
    var questionnaireTableView = UITableView()
    
    static var questionnaireList = [QuestionnaireType]()
    var todoQList = [QuestionnaireType]()
    var completeQList = [QuestionnaireType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        setTableViewDelegates()
        tableView.rowHeight = 70
        
        tableView.pin(to: view)
    }
    
    func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateQuestionnaireList()
    }
    
    /*
    func setTableView() {
        questionnaireTableView.frame = self.view.frame
        questionnaireTableView.delegate = self
        questionnaireTableView.dataSource = self
        questionnaireTableView.separatorColor = UIColor.gray
        questionnaireTableView.backgroundColor = UIColor.white
        questionnaireTableView.rowHeight = 70
        
        self.view.addSubview(self.questionnaireTableView)
        
        questionnaireTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    */
    
    func populateQuestionnaireList() {
        
        let questionnaireConverter = FHIRtoRKConverter()
        
        let ed = ExternalStoreDelegate()
        
        SurveyListViewController.questionnaireList.removeAll()
        SurveyListViewController.buttonTopCoordinate = SurveyListViewController.startingButtonTopCoordinate
        
        SurveyListViewController.startingButtonTopCoordinate = Int(self.contentView.frame.minY) + 5
        
        ed.getTasksFromServer { (tasks, error) in
            
            var tagNum = 0
            
            for task in tasks! {
                let questionnaireId = task.basedOn?[0].reference?.string
                questionnaireConverter.extractSteps(reference: questionnaireId!, task: task) { (questionnaire, error) in
                    DispatchQueue.main.async {
                        let questionnaireTitle = (questionnaire?.FHIRquestionnaire.title?.string)!
                        questionnaire?.tagNum = tagNum
                        
                        SurveyListViewController.questionnaireList.append(questionnaire!)
                        tagNum += 1
                        /*
                        DispatchQueue.main.async {
                            
                            if questionnaire!.FHIRtask.status?.rawValue != "completed" {
                               
                                /*
                                self.contentView.addSubview(self.makeNewButton(text: questionnaireTitle, newTag: tagNum, complete: false))
                                
                                self.surveyListLoadingIndicator.isHidden = true
                                */
                                
                                self.completeButtonList[tagNum] = questionnaireTitle
                                    tagNum += 1
                                  
                            } else {
                                
                                self.todoButtonList[tagNum] = questionnaireTitle
                                tagNum += 1
                                
                            }
                            
                            if tagNum == taskParser.questionnaireIdList.count {
                                print("TAGNUM REACHED MAX")
                                
                                for (buttonTag,buttonTitle) in self.buttonList {
                                    self.contentView.addSubview(self.makeNewButton(text: buttonTitle, newTag: buttonTag, complete: true))
                                }
                                
                                self.surveyListLoadingIndicator.isHidden = true
                                
                            }
                        }*/
                        if tagNum == taskParser.questionnaireIdList.count {
                            print("TAGNUM REACHED MAX")
                            //self.setTableView()
                            self.surveyListLoadingIndicator.isHidden = true
                        }
                    }
                    
                }
            }
            
        }
    }
    
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


}

extension SurveyListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SurveyListViewController.questionnaireList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? CustomTableViewCell else {fatalError("Unable to create cell")}
        cell.button.setTitle(SurveyListViewController.questionnaireList[indexPath.row].FHIRquestionnaire.title?.string, for: .normal)
        cell.button.setTitleColor(UIColor.black, for: .normal)
        cell.button.contentHorizontalAlignment = .left
        cell.button.tag = SurveyListViewController.questionnaireList[indexPath.row].tagNum
        cell.button.addTarget(self, action: #selector(SurveyListViewController.surveyClicked), for: .touchUpInside)
        
        return cell
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
            
            // update locally
            SurveyListViewController.questionnaireList[FHIRtoRKConverter.currentIndex].FHIRtask.status = TaskStatus(rawValue: "completed")
            let questionnaireId = SurveyListViewController.questionnaireList[FHIRtoRKConverter.currentIndex].FHIRtask.basedOn![0].reference?.string
            taskParser.questionnaireIdList[questionnaireId!] = true
            
            // update in server
            let task = SurveyListViewController.questionnaireList[FHIRtoRKConverter.currentIndex].FHIRtask
            task.update(callback: { error in
                print(error)
            })
            
            // TODO: make change visible in UI when taskViewController is dismissed
            
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

/*
func makeNewButton(text: String, newTag: Int, complete: Bool) -> UIButton {
    let newButton = UIButton(type: UIButton.ButtonType.system)
    // let buttonWidth = Int(self.backView.frame.width)
    
    newButton.setTitle(text, for: .normal)
    
    newButton.frame(forAlignmentRect: CGRect(x: SurveyListViewController.buttonGap, y: SurveyListViewController.buttonTopCoordinate, width: buttonWidth, height: SurveyListViewController.buttonHeight))
    
    if complete {
        newButton.backgroundColor = UIColor(cgColor: CGColor(red: 0, green: 0, blue: 0, alpha: 0.3))
        newButton.setTitleColor(UIColor.darkGray, for: .normal)
        newButton.layer.borderWidth = 2
        newButton.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    } else {
        newButton.backgroundColor = UIColor(cgColor: CGColor(red: 0.4, green: 0, blue: 0.6, alpha: 0.5))
        newButton.setTitleColor(UIColor.black, for: .normal)
        newButton.layer.borderWidth = 2
        newButton.layer.borderColor = CGColor(red: 0.4, green: 0, blue: 0.6, alpha: 1)
        /*
        newButton.addTarget(self, action: #selector(SurveyListViewController.surveyClicked), for: .touchUpInside)
        */
    }
    
    newButton.bounds = CGRect(x: 0, y: 0, width: buttonWidth, height: SurveyListViewController.buttonHeight)
    newButton.center = CGPoint(x: Int(view.frame.size.width)/2, y: Int(SurveyListViewController.buttonTopCoordinate + SurveyListViewController.buttonHeight/2))

    newButton.tag = newTag
    
    SurveyListViewController.buttonTopCoordinate += SurveyListViewController.buttonHeight + SurveyListViewController.buttonGap
    
    return newButton
}
 */
    
    
  
