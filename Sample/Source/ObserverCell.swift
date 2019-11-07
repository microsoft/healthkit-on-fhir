//
//  ObserverCell.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit

open class ObserverCell : UITableViewCell {
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    var code: String?
}
