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
    navigationController?.popViewController(animated: true)
  }
  
  var context: NSManagedObjectContext?
  var selectedItemIdentifiers: [NSManagedObjectID] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.setHidesBackButton(true, animated: false)
    
    costTextField?.delegate = self
    countSelectedItemsLabel.text = "You have selected \(selectedItemIdentifiers.count) items."
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
}
