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
        formatter.timeStyle = .none
        return formatter
    }()
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Subscribe to QueryObserver finished execution notifications
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: QueryObserverDelegate.observerUpdated, object: nil)

        refresh(nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refresh(_ notification: Notification?) {
        updateViewState(isLoading: true, message: "Fetching Observations")
        
        if let server = smartClient?.server {
            server.fetchAuthenticatedPatient { (patient, error) in
                guard error == nil else {
                    self.showErrorAlert(error: error!)
                    return
                }
                
                if let id = patient?.id?.description {
                    Observation.search(["code" : self.code, "subject" : id]).perform(server) { (bundle, error) in
                        if let results: [Observation] = bundle?.resources() {
                            self.observations = results
                            print(results[0])
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                        self.updateViewState(isLoading: false)
                    }
                }
            }
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        if segue.identifier == "ObservationSegue",
            let observationViewController = segue.destination as? ObservationViewController,
            let cell = sender as? ObservationCell,
            let observation = cell.observation {
            observationViewController.observation = observation
        }
    }
    
    /// Mark - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return observations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: ObservationListViewController.CellIdentifier, for: indexPath) as? ObservationCell {
            cell.observation = observations[indexPath.row]
            
            if let dateTime = cell.observation!.effectiveDateTime?.nsDate {
                cell.dateLabel.text = dateFormatter.string(from: dateTime)
                cell.timeLabel.text = timeFormatter.string(from: dateTime)
            }
            else if let start = cell.observation!.effectivePeriod?.start?.nsDate,
                let end = cell.observation!.effectivePeriod?.end?.nsDate {
                cell.dateLabel.text = dateFormatter.string(from: start)
                cell.timeLabel.text = "\(timeFormatter.string(from: start)) - \(timeFormatter.string(from: end))"
             }
            
            return cell
        }
        
        return UITableViewCell()
    }

}
