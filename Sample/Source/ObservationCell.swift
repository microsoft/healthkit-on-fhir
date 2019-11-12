//
//  ObservationCell.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import FHIR

open class ObservationCell : UITableViewCell {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    var observation: Observation?
}
