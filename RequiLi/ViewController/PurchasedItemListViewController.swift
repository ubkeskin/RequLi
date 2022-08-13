//
//  PurchasedItemListViewController.swift
//  RequiLi
//
//  Created by OS on 8.08.2022.
//

import UIKit
import CoreData

class PurchasedItemListViewController: UITableViewController {
  var context: NSManagedObjectContext?
  private var selectedCellObject: NSManagedObject?

  private lazy var fetchResultController: NSFetchedResultsController<PurchasedThingsModel>? = {
    guard let context = context else {
      return nil
    }

    let fetchRequest: NSFetchRequest<PurchasedThingsModel> = PurchasedThingsModel.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]

    
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: context,
                                         sectionNameKeyPath: nil,
                                         cacheName: nil)
    frc.delegate = self
    return frc
  }()
  
  private lazy var dataSource: UITableViewDiffableDataSource<String, NSManagedObjectID> = {
    let dataSource = UITableViewDiffableDataSource<String,NSManagedObjectID>(tableView: self.tableView) { tableView, indexPath, id in
      guard let purchasedItems = (self.context?.object(with: id) as? PurchasedThingsModel) else {
        fatalError("object could not cast into PurchasedItemModel")
      }
      guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchasedItemsRowCell.reuseIdentifier, for: indexPath) as? PurchasedItemsRowCell else {
        fatalError("")
      }

      cell.purchaseDate.text = purchasedItems.date?.formatted(date: .numeric, time: .omitted)
      cell.numberOfRow?.text = "\(indexPath.row + 1)"
      cell.purchaseAmount!.text = "\(purchasedItems.cost) $"
      
      return cell
    }
    tableView.dataSource = dataSource
    return dataSource
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initFetchResultController()
  }
  
  func initFetchResultController() {
    do {
      try fetchResultController?.performFetch()
    }
    catch {
      fatalError("perform Fetch Error")
    }
  }
  // MARK: -Fetch Result Controller
  
}
extension PurchasedItemListViewController: NSFetchedResultsControllerDelegate{
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    let mysnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
    dataSource.apply(mysnapshot)
  }
}

// MARK: -Prepare for Segue
extension PurchasedItemListViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "ShowPurchasedItemsViewController": if let controller = segue.destination as? PurchasedItemsViewController {
      handlePurchasedItemsViewSegue(controller)
    }
    default: return
    }
  }
  
  func handlePurchasedItemsViewSegue(_ controller: PurchasedItemsViewController) {
    controller.context = context
    controller.objectForSelectedCell = selectedCellObject
  }
}

// MARK: -Table View Functions

extension PurchasedItemListViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedCellDataSourceIndexPath = tableView.dataSourceIndexPath(forPresentationIndexPath: indexPath) else { return }
    guard let selectedCellDataIdentifier = dataSource.itemIdentifier(for: selectedCellDataSourceIndexPath) else { return }
    let selectedCellData = context?.object(with: selectedCellDataIdentifier)
    selectedCellObject = selectedCellData
    performSegue(withIdentifier: "ShowPurchasedItemsViewController", sender: nil)
  }
}
