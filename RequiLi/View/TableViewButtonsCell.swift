//
//  TableViewButtons.swift
//  RequiLi
//
//  Created by OS on 16.08.2022.
//

import UIKit

class TableViewButtonsCell: UITableViewCell {
  static let reuseIdentifier = String(describing: TableViewButtonsCell.self)
  
  @IBOutlet var save: UIButton?
  @IBOutlet var cancel: UIButton?
}
