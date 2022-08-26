//
//  SelectdItemsViewController.swift
//  RequiLi
//
//  Created by OS on 8.08.2022.
//

import UIKit
import CoreData

class SelectedItemsViewController: UITableViewController {
  @IBOutlet var countSelectedItemsLabel: UILabel!
  @IBOutlet var purchaseDatePicker: UIDatePicker?
  @IBOutlet var costTextField: UITextField?
  @IBAction func save() {
    updateData()
  }
  
  @IBAction func cancel() {
    
//    guard let controller = navigationController?.topViewController as? MainViewController else { return }
//    handlePopMainViewController(controller: controller)
//    navigationController?.popViewController(animated: true)
    
  }
  
  @IBAction func setDatePicker(sender: UIDatePicker) {
    
    self.purchaseDatePicker = sender
    
  }
  
  var context: NSManagedObjectContext?
  
  var selectedItemIdentifiers: [NSManagedObjectID] = []
  
  private var items: [ItemModel]{
    var items: [ItemModel] = []
    selectedItemIdentifiers.forEach { objectID in
      let itemModel = context?.object(with: objectID) as? ItemModel
      items.append(itemModel!)
    }
    return items
  }
  
//  private lazy var dataSource: UITableViewDiffableDataSource<ItemCategory, ItemModel>? = {
//    var dataSource = UITableViewDiffableDataSource<ItemCategory, ItemModel>(tableView: tableView) { tableView, indexPath, itemIdentifier in
//      guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewShowItemCell.reuseIdentifier, for: [1,0]) as? TableViewShowItemCell else {
//        fatalError()
//      }
//      cell.label?.text = itemIdentifier.name
//      cell.tableImage?.image = UIImage(data: itemIdentifier.attribute!)
//      
//      return cell
//    }
//    tableView.dataSource = dataSource
//    return dataSource
//  }()
 
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.setHidesBackButton(true, animated: false)
    tabBarController?.tabBar.isHidden = true
    configureLayoutColors()
    
        
    costTextField?.delegate = self
//    configureSnapshot()
//    countSelectedItemsLabel.text = "You have selected \(selectedItemIdentifiers.count) items."
    
      
  }
  
  
  private func updateData() {
    guard let context = context,
          let date = purchaseDatePicker?.date
          
    else {
      return
    }
    let cost = filterCostTextField()
    let purchasedThings = PurchasedThingsModel(context: context)
    var set = Set<ItemModel>()
    
    selectedItemIdentifiers.forEach({ objectID in
    set.update(with: (context.object(with: objectID) as? ItemModel)!)
      })
  
    purchasedThings.cost = cost
    purchasedThings.date = date
    purchasedThings.items = set
    
    do {
      try context.save()
    } catch  {
      fatalError("context could not save item")
    }

  }
  private func filterCostTextField() -> Double {
    guard let cost = costTextField else {
      return 0.0
    }

    let filtered = cost.text?.filter {$0.isNumber}
    let doubleCost = Double(filtered!)
    return doubleCost ?? 0
  }
}

// MARK: -UITable View Data Source
extension SelectedItemsViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    5
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 1 {
      return items.count
    } else {
      return 1
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0: guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewNumberOfItemsCell.reuseIdentifier, for: indexPath) as? TableViewNumberOfItemsCell
      else {
        fatalError()
      }
      cell.label?.text = "You have seleceted \(selectedItemIdentifiers.count) items."
      return cell
    case 1: guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewShowItemCell.reuseIdentifier, for: indexPath) as? TableViewShowItemCell else {
        fatalError()
      }
      
      cell.label?.text = items[indexPath.row].name
      cell.tableImage?.image = UIImage(data: items[indexPath.row].attribute!)
  
      return cell
      //      cell.label?.text = items[indexPath.row].name
//      cell.tableImage?.image = UIImage(data: items[indexPath.row].attribute!)
    case 2: guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewSelectDateCell.reuseIdentifier, for: indexPath) as? TableViewSelectDateCell else { fatalError()}
      
//      NotificationCenter.default.addObserver(self, selector: #selector(setDatePicker(sender:)), name: .datePickerIsChanged, object: cell.purchaseDatePicker)
//      NotificationCenter.default.post(name: .datePickerIsChanged, object: cell.purchaseDatePicker)
      cell.purchaseDatePicker?.addTarget(self, action: #selector(setDatePicker(sender:)), for: .allEvents)
      self.purchaseDatePicker = cell.purchaseDatePicker
      return cell
    case 3: guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewPurchaseCostCell.reuseIdentifier, for: indexPath) as? TableViewPurchaseCostCell else { fatalError()}
      cell.costTextField?.delegate = self
      costTextField = cell.costTextField
      return cell
    case 4:guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewButtonsCell.reuseIdentifier, for: indexPath) as? TableViewButtonsCell else { fatalError()}
      
      return cell
    default:
      fatalError()
    }
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section == 1 {
      return true
    } else {
      return false
    }
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      var itemIds = selectedItemIdentifiers
      self.tableView.beginUpdates()
      itemIds.removeAll { object in
        selectedItemIdentifiers[indexPath.row] == object
      }
      selectedItemIdentifiers = itemIds
      self.tableView.deleteRows(at: [indexPath], with: .fade)
      self.tableView.reloadRows(at: [[0,0]], with: .fade)
      self.tableView.endUpdates()
      
    }
  }
  
  
  
  
}

// MARK: -Fetch Results Controller Delegate
extension SelectedItemsViewController: NSFetchedResultsControllerDelegate {
//  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//    let mysnapshot = snapshot as NSDiffableDataSourceSnapshot<String, NSManagedObjectID>
////    dataSource?.apply(mysnapshot)
//  }
}


// MARK: -UITextFieldDelegate

extension SelectedItemsViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if costTextField == textField {
      addDoneButtonOnKeyboard()
    }
  }
  
  func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    true
  }
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if costTextField == textField {
      return textField.resignFirstResponder()
    }
    self.view.endEditing(true)
    return true
    
  }
  //MARK: Done Bar Button n Text Field
  func addDoneButtonOnKeyboard()
      {
          let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
          doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let ddone: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))

          var items = [UIBarButtonItem]()
          items.append(flexSpace)
          items.append(ddone)

          doneToolbar.items = items
          doneToolbar.sizeToFit()

        self.costTextField?.inputAccessoryView = doneToolbar
      }
  
  @objc func doneButtonAction() {
    costTextField?.endEditing(true)
  }
}

//MARK: Prepare For Segue

extension SelectedItemsViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
  case "ShowPurchasedItemsList":
      if let controller = segue.destination as? PurchasedItemListViewController {
        handlePurchasedItemsListSegue(controller)
      }
  default: return
    }
  }
  
  
  
  func handlePurchasedItemsListSegue(_ controller: PurchasedItemListViewController) {
    controller.context = self.context
  }
  
//  func handlePopMainViewController(controller: MainViewController) {
//    controller.context = self.context
//    controller.selectedItemIdentifiers = selectedItemIdentifiers
//  }
}

// MARK: Color Configuration
extension SelectedItemsViewController {
  private func configureLayoutColors() {
    let navigationBarAppearence = UINavigationBarAppearance()
    navigationBarAppearence.configureWithDefaultBackground()
    navigationBarAppearence.backgroundColor = UIColor(named: "NavigationBarColor")
    
    navigationBarAppearence.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    
    navigationItem.standardAppearance = navigationBarAppearence
    navigationItem.compactAppearance = navigationBarAppearence
    navigationItem.scrollEdgeAppearance = navigationBarAppearence
    navigationItem.leftBarButtonItem?.tintColor = .white
    navigationItem.rightBarButtonItem?.tintColor = .white
    
    let tabBarAppearence = UITabBarAppearance()
    tabBarAppearence.configureWithTransparentBackground()
    tabBarAppearence.backgroundColor = UIColor(named: "NavigationBarColor")
    
    
    tabBarController?.tabBar.standardAppearance = tabBarAppearence
    tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearence
    
    tableView.backgroundColor = UIColor(named: "BackgroundColor")
    
    
        
  }
}


