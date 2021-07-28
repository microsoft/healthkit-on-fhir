//
//  CustomTableViewCell.swift
//  researchKitOnFhir
//

import Foundation
import UIKit

public class CustomTableViewCell: UITableViewCell {
    
    var questionnaireLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(questionnaireLabel)
        configureButton()
        setButtonConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(questionnaire: QuestionnaireType) {
        questionnaireLabel.text = questionnaire.FHIRquestionnaire.title?.string
        questionnaireLabel.textColor = UIColor.black
        questionnaireLabel.textAlignment = .left
        questionnaireLabel.tag = questionnaire.tagNum
    }
    
    func configureButton() {
        questionnaireLabel.numberOfLines = 0
        questionnaireLabel.adjustsFontSizeToFitWidth = true
    }
    
    func setButtonConstraints() {
        questionnaireLabel.translatesAutoresizingMaskIntoConstraints = false
        questionnaireLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        questionnaireLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        questionnaireLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        questionnaireLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
