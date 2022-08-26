//
//  TableViewSelectDateCell.swift
//  RequiLi
//
//  Created by OS on 15.08.2022.
//

import UIKit

class TableViewPurchaseCostCell: UITableViewCell {
  static let reuseIdentifier = String(describing: TableViewPurchaseCostCell.self)
  
  @IBOutlet var label: UILabel?
  @IBOutlet var costTextField: UITextField?
}
