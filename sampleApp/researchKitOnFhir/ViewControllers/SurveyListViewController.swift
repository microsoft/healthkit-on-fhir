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
    
    struct Cells {
        static let buttonCell = "buttonCell"
    }
    
    let tableView = UITableView()
    
    static var questionnaireList = [QuestionnaireType]() // this one currently
    var todoQList = [QuestionnaireType]()
    var completeQList = [QuestionnaireType]()
    
    static var QList = [QListCategory]()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureTableView() {
        self.view.addSubview(tableView)
        setTableViewDelegates()
        tableView.rowHeight = 50
        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: Cells.buttonCell)
        tableView.pin(to: view)
    }
    
    func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateQuestionnaireList()
    }
    
    func populateQuestionnaireList() {
        
        let questionnaireConverter = FHIRtoRKConverter()
        
        let ed = ExternalStoreDelegate()
        
        SurveyListViewController.questionnaireList.removeAll()
        
        ed.getTasksFromServer { (tasks, error) in
            
            var tagNum = 0
            
            for task in tasks! {
                let questionnaireId = task.basedOn?[0].reference?.string
                questionnaireConverter.extractSteps(reference: questionnaireId!, task: task) { (questionnaire, error) in
                    DispatchQueue.main.async {
                        let questionnaireTitle = (questionnaire?.FHIRquestionnaire.title?.string)!
                        questionnaire?.tagNum = tagNum
                        
                        if questionnaire!.FHIRtask.status?.rawValue != "completed" {
                        
                            self.todoQList.append(questionnaire!)
                            tagNum += 1
                                  
                        } else {
                                
                            self.completeQList.append(questionnaire!)
                            tagNum += 1
                                
                        }
                        
                        if tagNum == self.todoQList.count + self.completeQList.count {
                            print(self.todoQList)
                            print(self.completeQList)
                            print(SurveyListViewController.questionnaireList.count)
                            self.createQListCategories(todoQ: self.todoQList, completeQ: self.completeQList)
                            self.configureTableView()
                            self.surveyListLoadingIndicator.isHidden = true
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    func createQListCategories(todoQ: [QuestionnaireType], completeQ: [QuestionnaireType]) {
        let todoQItem = QListCategory(completion: "Requested", questionnaires: todoQ)
        let completeQItem = QListCategory(completion: "Completed", questionnaires: completeQ)
        SurveyListViewController.QList.append(todoQItem)
        SurveyListViewController.QList.append(completeQItem)
    }
    
    @IBOutlet weak var surveyListLoadingIndicator: UIActivityIndicatorView!

    func surveySelected(tagNum: Int) {
        let fhirToRk = FHIRtoRKConverter()
        let questionnaire = SurveyListViewController.questionnaireList[tagNum]
        
        let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: fhirToRk.getORKStepsFromQuestionnaire(questionnaire: questionnaire.FHIRquestionnaire))
        
        let taskViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
        taskViewController.delegate = self
        FHIRtoRKConverter.currentIndex = tagNum
        self.present(taskViewController, animated: true, completion: nil)
    }

}

extension SurveyListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SurveyListViewController.QList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cells.buttonCell, for: indexPath) as? CustomTableViewCell else {fatalError("Unable to create cell")}
        
        print("SECTION: \(indexPath.section). ROW: \(indexPath.row)")
        let questionnaire = SurveyListViewController.QList[indexPath.section].questionnairesDisplayed![indexPath.row]
        cell.set(questionnaire: questionnaire)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.width, height: 35))
        headerView.addSubview(label)
        label.backgroundColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        label.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20).isActive = true
        label.text = SurveyListViewController.QList[section].completionHeader
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        surveySelected(tagNum: indexPath.row)
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
            print("REASON: discarded")
            
        case .failed:
            taskViewController.dismiss(animated: true, completion: nil)
            print("REASON: failed")
            
        @unknown default:
            print("REASON: unknown default")
        }
    }
}
