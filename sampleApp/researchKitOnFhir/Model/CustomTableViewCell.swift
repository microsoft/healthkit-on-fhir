//
//  CustomTableViewCell.swift
//  researchKitOnFhir
//
//  Created by admin on 7/22/21.
//

import Foundation
import UIKit

public class CustomTableViewCell: UITableViewCell {
    
    var button = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(button)
        configureButton()
        setButtonConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(questionnaire: QuestionnaireType) {
        button.text = questionnaire.FHIRquestionnaire.title?.string
        button.textColor = UIColor.black
        button.textAlignment = .left
        button.tag = questionnaire.tagNum
    }
    
    func configureButton() {
        button.numberOfLines = 0
        button.adjustsFontSizeToFitWidth = true
    }
    
    func setButtonConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25).isActive = true
        button.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
