//
//  ObservationListViewController.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import FHIR

class ObservationListViewController: ViewControllerBase, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    public var code: String?
    
    private var observations = [Observation]()
    private static let CellIdentifier = "ObservationCell"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe to QueryObserver finished execution notifications
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: QueryObserverDelegate.observerUpdated, object: nil)

        refresh(nil)
        
        updateViewState(isLoading: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refresh(_ notification: Notification?) {
        if let server = smartClient?.server {
            server.fetchAuthenticatedPatient { (patient, error) in
                guard error == nil else {
                    self.showErrorAlert(error: error!)
                    return
                }
                
                if let id = patient?.id?.description {
                    Observation.search(["code" : self.code, "subject" : id]).perform(server) { (bundle, error) in
                        if let results: [Observation] = bundle?.resources() {
                            self.observations.append(contentsOf: results)
                            print(results[0])
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    public override func updateViewState(isLoading: Bool, message: String? = nil) {
       super.updateViewState(isLoading: isLoading, message: message)
        
        DispatchQueue.main.async {
        }
    }
    
    /// Mark - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ObservationListViewController.CellIdentifier, for: indexPath) as? ObserverCell {
            return cell
        }
        
        return UITableViewCell()
    }

}
