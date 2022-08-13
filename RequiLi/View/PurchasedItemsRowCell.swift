//
//  PurchasedItemsRowCell.swift
//  RequiLi
//
//  Created by OS on 10.08.2022.
//

import Foundation
import UIKit

final class PurchasedItemsRowCell: UITableViewCell {
  static let reuseIdentifier = "PurchasedItemsRowCell"
  
  @IBOutlet var numberOfRow: UILabel?
  @IBOutlet var purchaseDate: UILabel!
  @IBOutlet var purchaseAmount: UILabel?

}
