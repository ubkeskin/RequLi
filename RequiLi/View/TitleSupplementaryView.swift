//
//  TitleSupplamentaryView.swift
//  RequiLi
//
//  Created by OS on 26.07.2022.
//

import UIKit

class TitleSupplementaryView: UICollectionReusableView{
  static let reuseIdentifier = String(describing: TitleSupplementaryView.self)
  
  @IBOutlet var textLabel: UILabel!
  @IBOutlet var backgroundImage: UIImageView!
  
//  override init(frame: CGRect) {
//    super.init(frame: frame)
//    configure()
//  }
//
//  required init?(coder: NSCoder) {
//    fatalError("init(coder:) is not implemented")
//  }
//
//  private func configure() {
//    addSubview(textLabel)
//    textLabel.font = UIFont.preferredFont(forTextStyle: .title2)
//    textLabel.translatesAutoresizingMaskIntoConstraints = false
//
//    addSubview(backgroundImage)
//    backgroundImage.translatesAutoresizingMaskIntoConstraints = false
//
//
//
//    let inset: CGFloat = 10
//
//    NSLayoutConstraint.activate([
//      backgroundImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
//      backgroundImage.topAnchor.constraint(equalTo: topAnchor, constant: inset),
//      backgroundImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: inset),
//      backgroundImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: inset),
//      textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
//      textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
//      textLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset),
//      textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset)
//    ])
//  }
}
