//
//  ItemCell.swift
//  RequiLi
//
//  Created by OS on 24.07.2022.
//

import UIKit

class ItemCell: UICollectionViewCell {
  static let reuseIdentifier = String(describing: ItemCell.self)
  
  
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var compactImageView: UIImageView!
  
  }


