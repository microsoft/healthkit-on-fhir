//
//  SurveyListViewController.swift
//  ResearchKitOnFhir
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.
//

import UIKit
import ResearchKit
import SMART

class SurveyListViewController: UIViewController {
    
    var smartClient: Client?
    var didAttemptAuthentication = false
    static var questionnaireList = [Int: QuestionnaireType]()
    var todoQList = [QuestionnaireType]()
    var completeQList = [QuestionnaireType]()
    let tableView = UITableView()
    static var QList = [QListCategory]()
    
    struct SectionTitles {
        static let toDo = "Requested"
        static let complete = "Complete"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(QuestionnaireListTableViewCell.self, forCellReuseIdentifier: QuestionnaireListTableViewCell.buttonCellIdentifier)
    }
    
    func configureTableView() {
        self.view.addSubview(tableView)
        setTableViewDelegates()
        tableView.reloadData()
        tableView.rowHeight = 50
        tableView.pin(to: view)
    }
    
    func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SurveyListViewController.QList.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateQuestionnaireList()
    }
    
    func populateQuestionnaireList() {
        
        let questionnaireConverter = FhirToResearchKitConverter()
        
        let ed = ExternalStoreDelegate()
        
        SurveyListViewController.QList.removeAll()
        SurveyListViewController.questionnaireList.removeAll()
        self.todoQList.removeAll()
        self.completeQList.removeAll()
        
        ed.getTasksFromServer { (tasks, error) in
            
            var counter = 0
            
            for task in tasks! {
                
                let questionnaireId = task.basedOn?[0].reference?.string
                questionnaireConverter.extractSteps(reference: questionnaireId!, task: task) { (questionnaire, error) in
                        DispatchQueue.main.async {
                        
                            if questionnaire != nil {
                                if questionnaire!.FHIRtask.status?.rawValue != "completed" {
                                    
                                    self.todoQList.append(questionnaire!)
                                    
                                } else {
                                    
                                    self.completeQList.append(questionnaire!)
                                    
                                }
                            }
                            counter += 1
                            
                            if counter == tasks?.count {
                                
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
        let todoQItem = QListCategory(completion: SectionTitles.toDo, questionnaires: todoQ)
        let completeQItem = QListCategory(completion: SectionTitles.complete, questionnaires: completeQ)
        if todoQ.count > 0 {
            SurveyListViewController.QList.append(todoQItem)
        }
        if completeQ.count > 0 {
            SurveyListViewController.QList.append(completeQItem)
        }
        assignTagNums()
    }
    
    func assignTagNums() {
        var tagNum = 0
        for questionnaireSection in SurveyListViewController.QList {
            for questionnaire in questionnaireSection.questionnairesDisplayed! {
                questionnaire.tagNum = tagNum
                SurveyListViewController.questionnaireList[tagNum] = questionnaire
                tagNum += 1
            }
        }
    }
    
    @IBOutlet weak var surveyListLoadingIndicator: UIActivityIndicatorView!
    
    func surveySelected(tagNum: Int) {
        let FhirToResearchKit = FhirToResearchKitConverter()
        let questionnaire = SurveyListViewController.questionnaireList[tagNum]
        
        let surveyTask = ORKOrderedTask(identifier: title ?? "Questionnaire", steps: FhirToResearchKit.getORKStepsFromQuestionnaire(questionnaire: questionnaire!.FHIRquestionnaire))
        
        let taskViewController = ORKTaskViewController(task: surveyTask, taskRun: nil)
        taskViewController.delegate = self
        FhirToResearchKitConverter.currentIndex = tagNum
        self.present(taskViewController, animated: true, completion: nil)
    }
}

extension SurveyListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SurveyListViewController.QList[section].questionnairesDisplayed?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireListTableViewCell.buttonCellIdentifier, for: indexPath) as? QuestionnaireListTableViewCell else {fatalError("Unable to create cell")}
        
        let questionnaire = SurveyListViewController.QList[indexPath.section].questionnairesDisplayed?[indexPath.row]
        cell.set(questionnaire: questionnaire!)
        
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
        if SurveyListViewController.QList[indexPath.section].completionHeader == SectionTitles.toDo {
            let tagNum = (SurveyListViewController.QList[indexPath.section].questionnairesDisplayed?[indexPath.row].tagNum)!
            surveySelected(tagNum: tagNum)
        }
    }
    
}

extension SurveyListViewController: ORKTaskViewControllerDelegate  {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        
        switch (reason) {
        case .completed:
            
            persistResultsAsQResponse(taskViewController)
            updateTaskStatus(taskViewController)
             
        case .discarded:
            taskViewController.dismiss(animated: true, completion: nil)
            print("REASON: discarded")
            
        case .failed:
            taskViewController.dismiss(animated: true, completion: nil)
            print("REASON: failed")
            
        case .saved:
            taskViewController.dismiss(animated: true, completion: nil)
        @unknown default:
            taskViewController.dismiss(animated: true, completion: nil)
            print("REASON: unknown default")
        }
    }
    
    fileprivate func persistResultsAsQResponse (_ taskViewController: ORKTaskViewController) {
        let questionnaireConverter = ResearchKitToFhirConverter()
        
        // convert the questionnaire response from ResearchKit type to FHIR QuestionnaireResponse resource
        let FHIRQuestionnaireResponse: QuestionnaireResponse = questionnaireConverter.researchKitQuestionResponseToFhir(results: taskViewController)
        
        // set the questionnaireResponse's associated questionnaire
        FHIRQuestionnaireResponse.questionnaire = FHIRCanonical((SurveyListViewController.questionnaireList[FhirToResearchKitConverter.currentIndex]!.FHIRtask.basedOn?[0].reference?.string)!)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let smartClient = appDelegate?.smartClient
        
        // Post the response to the FHIR server
        FHIRQuestionnaireResponse.create(smartClient?.server as! FHIRServer) { (error) in
            //Ensure there is no error
            guard error == nil else {
                return
            }
        }
    }
    
    fileprivate func updateTaskStatus(_ taskViewController: ORKTaskViewController) {
        // update task completion status in server
        let task = SurveyListViewController.questionnaireList[FhirToResearchKitConverter.currentIndex]!.FHIRtask
        task.status = TaskStatus(rawValue: "completed")
        
        task.update(callback: { error in
            
            // ensure there is no error
            if error == nil {
                DispatchQueue.main.async {
                    self.view.subviews.forEach { (uiView) in
                        if uiView != self.surveyListLoadingIndicator {
                            uiView.removeFromSuperview()
                            self.surveyListLoadingIndicator.isHidden = false
                        }
                    }
                    self.populateQuestionnaireList()
                    taskViewController.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
}
