//
//  CustomTableViewCell.swift
//  researchKitOnFhir
//
//  Created by admin on 7/22/21.
//

import Foundation
import UIKit

public class CustomTableViewCell: UITableViewCell {
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addSubview(backView)
        backView.addSubview(button)
    }
    
    public override func layoutSubviews() {
        contentView.backgroundColor = UIColor.white
        backgroundColor = UIColor.white
        backView.layer.cornerRadius = 5
        backView.clipsToBounds = true
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
    }
    
    lazy var backView: UIView = buildBackView()
    lazy var button: UIButton = buildMemberButton()
        
    func buildBackView() -> UIView {
        let view = UIView(frame: CGRect(x: 5, y: 5, width: self.frame.width, height: self.frame.height))
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func buildMemberButton() -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 5, y: 5, width: backView.frame.width, height: backView.frame.height)
        return button
    }  
}
