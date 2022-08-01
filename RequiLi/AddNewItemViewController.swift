//
//  AddNewItemView.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//

import UIKit
import CoreData

class AddNewItemViewController: UITableViewController {
  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var categoryPicker: UIPickerView!
  @IBOutlet var energyTextField: UITextField!
  @IBOutlet var itemImageView: UIImageView!
  
  var itemCategories = ItemCategory.allCases
  var context: NSManagedObjectContext?
  var itemImageData: Data?
  

  override func viewDidLoad() {
    super.viewDidLoad()
    categoryPicker.dataSource = self
    categoryPicker.delegate = self
  }
  
  
  @IBAction func selectImage(_ sender: UIButton) {
  }
  @IBAction func saveNewItem(_ sender: Any) {
    updateData()
    do {
      try context?.save()
      dismiss(animated: true)
    } catch {
      fatalError("core data save error")
    }
    navigationController?.popViewController(animated: true)
  }
  @IBAction func cancel(_ sender: Any) {
    navigationController?.popViewController(animated: true)

  }
  
}

//MARK: -Extensions to AddNewItem

extension AddNewItemViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == nameTextField {
      return energyTextField.becomeFirstResponder()
    } else {
      return textField.resignFirstResponder()
    }
  }
  
  func updateData() {
    guard let context = context else { return }
    let newItem = ItemModel(context: context)
    newItem.name = nameTextField.text
    newItem.enerjyValue = filterEnerjyString()
    newItem.itemCategory = itemCategories[categoryPicker.selectedRow(inComponent: 0)]
    newItem.attribute = itemImageData
  }
  
  func filterEnerjyString() -> Int32 {
    let filtered = energyTextField.text?.filter {$0.isNumber}
    let stringToInt = Int32(filtered!)
    return stringToInt ?? 0
  }
  
}

extension AddNewItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
  ) {
    guard let image = info[.originalImage] as? UIImage else { return }
    self.itemImageView.image = image
    itemImageData = image.pngData()
    
    dismiss(animated: true, completion: nil)
  }
}


//MARK: -Configure Picker View

extension AddNewItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents( in pickerView: UIPickerView) -> Int {
    1
      }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    let itemCount = ItemCategory.allCases.count
    return itemCount

  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return itemCategories.map { itemCategory in
      itemCategory.info
    }[row]
  }
}























