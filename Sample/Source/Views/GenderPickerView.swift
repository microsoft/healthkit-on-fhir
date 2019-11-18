//
//  GenderPickerView.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import SMART

class GenderPickerView : UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @objc dynamic var selectedGenderString: NSString = ""
    public var selectedGender = AdministrativeGender.unknown
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderForRow(row: row).rawValue.capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGender = genderForRow(row: row)
        selectedGenderString = selectedGender == .unknown ? NSString(string: "") : NSString(string: selectedGender.rawValue.capitalized)
    }
    
    private func genderForRow(row: Int) -> AdministrativeGender {
        switch row {
        case 1:
            return .male
        case 2:
            return .female
        case 3:
            return .other
        default:
            return .unknown
        }
    }
}
