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
  
  @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
    
  }
  
  private lazy var dataSource: TableViewDataSource = {
    let dataSource = TableViewDataSource(tableView: self.tableView) { tableView, indexPath, id in
      guard let purchasedItems = (self.context?.object(with: id) as? PurchasedThingsModel) else {
        fatalError("object could not cast into PurchasedItemModel")
      }
      guard let cell = tableView.dequeueReusableCell(withIdentifier: PurchasedItemsRowCell.reuseIdentifier, for: indexPath) as? PurchasedItemsRowCell else {
        fatalError("")
      }
      
      
      
      cell.purchaseDate.text = purchasedItems.date?.formatted(date: .numeric, time: .omitted)
      cell.purchaseDate.textColor = UIColor(named: "TextColor")
      cell.numberOfRow?.text = purchasedItems.items.count <= 1 ? "\(purchasedItems.items.count) item" : "\(purchasedItems.items.count) items"
      cell.numberOfRow?.textColor = UIColor(named: "TextColor")
      cell.purchaseAmount!.text = "\(purchasedItems.cost) $"
      cell.purchaseAmount?.textColor = UIColor(named: "TextColor")
      cell.backgroundColor = UIColor.clear
      
      
      return cell
    }
    
    tableView.dataSource = dataSource
    return dataSource
  }()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = false
    
    tableView.reloadData()

  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBarController?.tabBar.isHidden = false
    navigationItem.setHidesBackButton(false, animated: false)
    
    configureNavigationAndTabBars()
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

// MARK: -UITable View Data Source

extension PurchasedItemListViewController {
  
}

extension PurchasedItemListViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedCellDataSourceIndexPath = tableView.dataSourceIndexPath(forPresentationIndexPath: indexPath) else { return }
    guard let selectedCellDataIdentifier = dataSource.itemIdentifier(for: selectedCellDataSourceIndexPath) else { return }
    let selectedCellData = context?.object(with: selectedCellDataIdentifier)
    selectedCellObject = selectedCellData
    performSegue(withIdentifier: "ShowPurchasedItemsViewController", sender: nil)
  }
  
}

// MARK: -Table View Functions

extension PurchasedItemListViewController {
  func configureNavigationAndTabBars() {
    let navigationBarAppearence = UINavigationBarAppearance()
    navigationBarAppearence.configureWithDefaultBackground()
    navigationBarAppearence.backgroundImage = UIImage(named: "RequiLi")
    navigationBarAppearence.backgroundColor = UIColor(named: "NavigationBarColor")
    
    navigationBarAppearence.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    
    navigationItem.standardAppearance = navigationBarAppearence
    navigationItem.compactAppearance = navigationBarAppearence
    navigationItem.scrollEdgeAppearance = navigationBarAppearence
    navigationItem.leftBarButtonItem?.tintColor = .white
    navigationItem.backBarButtonItem?.tintColor = .white
    navigationItem.rightBarButtonItem?.tintColor = .white
    
    var appearence = UITabBarAppearance()
    appearence.backgroundImage = UIImage(named: "BackgroundImage")
    
    tabBarController?.tabBar.standardAppearance = appearence
    tabBarController?.tabBar.scrollEdgeAppearance = appearence
    
    tableView.backgroundView = UIImageView(image: UIImage(named: "BackgroundImage"))
    tableView.backgroundColor?.withAlphaComponent(0)
    tableView.backgroundColor = UIColor.clear
    
  }
}
