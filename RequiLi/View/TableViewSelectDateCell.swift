//
//  TableViewSelectDateCell.swift
//  RequiLi
//
//  Created by OS on 15.08.2022.
//

import UIKit

class TableViewSelectDateCell: UITableViewCell {
  static let reuseIdentifier = String(describing: TableViewSelectDateCell.self)
  
  @IBOutlet var label: UILabel?
  @IBOutlet var purchaseDatePicker: UIDatePicker? = UIDatePicker()
}
