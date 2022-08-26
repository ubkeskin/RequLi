//
//  TableViewItemCell.swift
//  RequiLi
//
//  Created by OS on 15.08.2022.
//

import Foundation
import CoreData
import UIKit

class TableViewShowItemCell: UITableViewCell {
  static let reuseIdentifier = String(describing: TableViewShowItemCell.self)
  
  @IBOutlet var label: UILabel?
  @IBOutlet var tableImage: UIImageView?
  
}
