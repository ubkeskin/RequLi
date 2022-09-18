//
//  Extensions.swift
//  RequiLi
//
//  Created by OS on 7.08.2022.
//

import Foundation
import CoreData
import UIKit

extension Notification.Name {
  static let selectedIdentifiersUpdated = Notification.Name(rawValue: "SelectedIdentifiersUpdated")
  static let datePickerIsChanged = Notification.Name(rawValue: "DatePickerIsChanged")
  static let titleSupplementeryViewBackgroundUpdated = Notification.Name(rawValue: "TitleSupplementeryViewBackgroundUpdated")
}

class TableViewDataSource: UITableViewDiffableDataSource<String, NSManagedObjectID> {
  
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  
  
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
    guard let dataSourceIndex = tableView.dataSourceIndexPath(forPresentationIndexPath: indexPath) else {fatalError()}
    guard let purchasedObjectID = self.itemIdentifier(for: indexPath) else {fatalError()}
    
    let context = appDelegate!.persistentContainer.viewContext
    
    let object = context.object(with: purchasedObjectID)
    
    
    if editingStyle == .delete {
      
      
      context.delete(object)
      do {
        try context.save()
      } catch  {
        fatalError()
      }
    }
  }
}

