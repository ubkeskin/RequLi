//
//  BadgeLabelView.swift
//  RequiLi
//
//  Created by OS on 8.09.2022.
//

import UIKit

class BadgeLabelView: UILabel {
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    layer.borderColor = UIColor.clear.cgColor
    layer.borderWidth = 2
    layer.cornerRadius = 7
    textAlignment = NSTextAlignment.center
    font = UIFont.systemFont(ofSize: 10)
    layer.masksToBounds = true
    
    
    textColor = .white
    backgroundColor = UIColor(named: "TextColor")
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
