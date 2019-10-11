//
//  PatientOnboardingViewController.swift
//  HealthKitOnFhir_Sample
//
//  Copyright (c) Microsoft Corporation.
//  Licensed under the MIT License.

import Foundation
import UIKit
import SMART

class PatientOnboardingViewController : ViewControllerBase, UITextFieldDelegate, UIPickerViewDelegate {
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var genderPicker: GenderPickerView!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var givenField: UITextField!
    @IBOutlet var familyField: UITextField!
    @IBOutlet var dateOfBirthField: UITextField!
    @IBOutlet var genderField: UITextField!
    @IBOutlet var nextButton: UIBarButtonItem!
    @IBOutlet var scrollView: UIScrollView!

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldTextChanged(notification:)), name: UITextField.textDidChangeNotification, object: nil)
        
        dateOfBirthField.inputView = datePicker
        dateOfBirthField.inputAccessoryView = InputAccessoryView.new(buttonTitle: "Done", target: self, selector: #selector(inputAccessoryButtonPressed))
        genderPicker.addObserver(self, forKeyPath: "selectedGenderString", options: .new, context: nil)
        genderField.inputView = genderPicker
        genderField.inputAccessoryView = InputAccessoryView.new(buttonTitle: "Done", target: self, selector: #selector(inputAccessoryButtonPressed))
    }
    
    private func createResources()
    {
        // Show the loading indicator.
        updateViewState(isLoading: true)
        
        // Create the patient resource.
        createPatientResource { (patient, error) in
            guard error == nil,
                patient != nil else {
                self.showErrorAlert(error: error!)
                return
            }
            
            self.navigate(segueIdentifier: "OnboardingCompleteSegue")
        }
    }
    
    private func createPatientResource(callback: @escaping (Patient?, Error?) -> Void) {
        if let server = smartClient?.server,
            let claims = server.tokenClaims(),
            let issuer = claims["iss"] as? String,
            let subject = claims["sub"] as? String {
            
            // Create the new patient resource
            let patient = Patient.createPatient(given: givenField.text!, family: familyField.text!, dateOfBirth: datePicker.date, gender: genderPicker!.selectedGender)
            
            // Add the identifier from the identity provider
            let identifier = Identifier()
            identifier.system = FHIRURL(issuer)
            identifier.value = FHIRString(subject)
            patient?.identifier = [identifier]
            
            patient?.create(server, callback: { (error) in
                callback(patient, error)
            })
        }
    }
    
    private func isFormComplete() -> Bool {
        // Ensure all text fields are filled out
        for textField in textFields {
            if textField.text == nil || textField.text == "" {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func next(sender: UIButton) {
        // Create the patient and device resources
        if isFormComplete() {
            createResources()
        }
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        dateOfBirthField.text = dateFormatter.string(from: datePicker.date)
        nextButton.isEnabled = isFormComplete()
    }
    
    @objc override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "selectedGenderString" {
            genderField.text = String(genderPicker.selectedGenderString)
            nextButton.isEnabled = isFormComplete()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc private func inputAccessoryButtonPressed() {
        view.endEditing(true)
    }
    
    @objc private func textFieldTextChanged(notification: Notification) {
        nextButton.isEnabled = isFormComplete()
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let frame = view.convert(value.cgRectValue, to: view.window)
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16 + frame.height - view.safeAreaInsets.bottom, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    /// MARK - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dateOfBirthField {
            datePickerValueChanged(sender: datePicker)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

