//
//  ItemCell.swift
//  RequiLi
//
//  Created by OS on 24.07.2022.
//

import UIKit

class ItemCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: ItemCell.self)
  
  var isEditing: Bool = false
  
  override var isSelected: Bool {
    didSet {
      if isEditing {
        contentView.backgroundColor = isSelected ? UIColor.systemRed.withAlphaComponent(0.5) : UIColor.systemGroupedBackground
      }
      else {
        contentView.backgroundColor = nil
      }
    }
  }
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var compactImageView: UIImageView!
  
  }


