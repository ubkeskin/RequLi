//
//  BarButton.swift
//  RequiLi
//
//  Created by OS on 8.09.2022.
//

import UIKit

class BarButtonView: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setBackgroundImage(UIImage(systemName: "cart.circle"), for: .normal)
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
