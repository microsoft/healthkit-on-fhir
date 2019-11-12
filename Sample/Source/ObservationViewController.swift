//
//  ObservationViewController.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import FHIR

class ObservationViewController: ViewControllerBase {
    @IBOutlet var observationTextView: UITextView!
    public var observation: Observation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observationTextView.text = observation!.debugDescription
    }
}
