//
//  BackgroundReusableView.swift
//  RequiLi
//
//  Created by OS on 25.08.2022.
//

import UIKit

class BackgroundReusableView: UICollectionReusableView {
  static let reuseIdentity = String(describing: BackgroundReusableView.self)
  
  @IBOutlet var backgroundImage: UIImageView?
  
//  var backgroundImage = UIImageView()
  
//  private override init(frame: CGRect) {
//          super.init(frame: frame)
//
//          self.initialize()
//      }
//
//      @available(*, unavailable)
//      public required init?(coder aDecoder: NSCoder) {
//          fatalError("init(coder) isn not available")
//      }
//
//      open func initialize() {
//
//        addSubview(backgroundImage)
//
//        let inset = 10.0
//
//        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
//        backgroundImage.image = UIImage(named: "BackgroundImage")
//
//        NSLayoutConstraint.activate([
//          backgroundImage.topAnchor.constraint(equalTo: topAnchor, constant: inset),
//          backgroundImage.bottomAnchor.constraint(equalTo: self.bottomAnchor , constant: inset),
//          backgroundImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: inset),
//          backgroundImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: inset),
//        ])
//      }

  
  
}
