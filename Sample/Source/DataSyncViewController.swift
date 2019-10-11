//
//  DataSyncViewController.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import HealthDataSync

class DataSyncViewController: ViewControllerBase, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var permissionsButton: UIButton!
    @IBOutlet var syncViews: [UIView]!
    @IBOutlet var tableView: UITableView!
    
    private var syncManager: HDSManagerProtocol?
    private static let CellIdentifier = "ObserverCell"
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
        
        // The sync manager was created during the app launch, use the same instance here
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        syncManager = appDelegate?.syncManager
        updateViewState(isLoading: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refresh(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @IBAction func requestPermissions(sender: UIButton) {
        updateViewState(isLoading: true)
        
        syncManager?.requestPermissionsForAllObservers(completion: { (success, error) in
            self.showPermissionResult(success: success, error: error)
            self.updateViewState(isLoading: false)
        })
    }
    
    @IBAction func start(sender: UIButton) {
        if allObserversStarted() {
            if let queryObservers = syncManager?.allObservers {
                updateViewState(isLoading: true)
                executeAll(queryObservers: queryObservers, index: 0) {
                    self.updateViewState(isLoading: false)
                }
            }
        } else {
            syncManager?.startObserving()
        }
    }
    
    private func permissionsGranted() -> Bool {
        // Check the permission state of all observers in the sync manager.
        // If observer.canStartObserving == false, permission to query that specific HealthKit type has not been granted.
        if let observers = syncManager?.allObservers {
            for observer in observers {
                if !observer.canStartObserving {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func allObserversStarted() -> Bool {
        // Check the observing status of all observers in the sync manager.
        // If observer.canStartObserving == false, permission to query that specific HealthKit type has not been granted.
        if let observers = syncManager?.allObservers {
            for observer in observers {
                if !observer.isObserving {
                    return false
                }
            }
        }
        
        return true
    }
    
    private func executeAll(queryObservers: [HDSQueryObserver], index: Int, completion: @escaping () -> Void)
    {
        // All query observers have completed.
        guard index < queryObservers.count else {
            completion()
            return
        }
        
        // Call execute on each query observer and recurse.
        queryObservers[index].execute { (success, error) in
            self.executeAll(queryObservers: queryObservers, index: index + 1, completion: completion)
        }
    }
    
    private func showPermissionResult(success: Bool, error: Error?) {
        let title = success ? "Success" : "Error"
        let message = success ? "The request for access to health data was successful" : error?.localizedDescription
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    public override func updateViewState(isLoading: Bool, message: String? = nil) {
       super.updateViewState(isLoading: isLoading, message: message)
        
        DispatchQueue.main.async {
            if (!isLoading) {
                let hasPermissions = self.permissionsGranted()
                
                for view in self.contentViews {
                    view.isHidden = !hasPermissions
                }
    
                self.permissionsButton.isHidden = hasPermissions
            }
        }
    }
    
    /// Mark - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return syncManager?.allObservers.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: DataSyncViewController.CellIdentifier, for: indexPath) as? ObserverCell,
            let observer = syncManager?.allObservers[indexPath.row] {
            cell.typeLabel.text = String(describing: observer.externalObjectType)
            
            if let lastSyncDate = observer.lastSuccessfulExecutionDate {
                cell.dateLabel.text = dateFormatter.string(from: lastSyncDate)
            } else {
                cell.dateLabel.text = "Not Synced"
            }
            
            return cell
        }
        
        return UITableViewCell()
    }

}

