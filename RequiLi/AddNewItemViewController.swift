//
//  AddNewItemView.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//

import UIKit
import CoreData
import PhotosUI

class AddNewItemViewController: UITableViewController {
  @IBOutlet var nameTextField: UITextField!
  @IBOutlet var categoryPicker: UIPickerView!
  @IBOutlet var energyTextField: UITextField!
  @IBOutlet var itemImageView: UIImageView!
  
  @IBOutlet var selectImageButton: UIButton!
  @IBAction func selectImageAction() {
    let picker = UIImagePickerController()
    picker.sourceType =
    UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
    picker.delegate = self
    picker.allowsEditing = true
    
//    let alert = UIAlertController(title: "Allow Access to Your Photos", message: "As you want to add custom photo, you need to allow access.", preferredStyle: .alert)
//    let notNowAction = UIAlertAction(title: "Not Now", style: .cancel)
//    alert.addAction(notNowAction)
//
//    let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { [unowned self] (_) in
//      gotoAppPrivacySettings()
//    }
//
//    alert.addAction(openSettingsAction)
//
//
//    present(alert, animated: true, completion: nil)

    
    present(picker, animated: true)
  }
  
  
  var itemCategories = ItemCategory.allCases
  var context: NSManagedObjectContext?
  var itemImageData: Data? = UIImage(systemName: "r.square.fill")?.pngData()
  

  override func viewDidLoad() {
    super.viewDidLoad()
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
      DispatchQueue.main.async {
        [unowned self] in
        showUI(_for: status)
      }
    }
    tabBarController?.tabBar.isHidden = true 
    categoryPicker.dataSource = self
    categoryPicker.delegate = self
    
    configureLayoutColors()
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
    guard let context = context,
    let nameText = nameTextField.text else { return }
    
    let _ = ItemModel(name: nameText, category: itemCategories[categoryPicker.selectedRow(inComponent: 0)].rawValue, enerjyValue: filterEnerjyString(), attribute: itemImageData, purchasedThingsList: nil, context: context)
  }

  
  func filterEnerjyString() -> Int32 {
    let filtered = energyTextField.text?.filter {$0.isNumber}
    let stringToInt = Int32(filtered!)
    return stringToInt ?? 0
  }
  
}

//MARK: -ImagePickerControllerDelegate

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

// MARK: Color Configuration
extension AddNewItemViewController {
  private func configureLayoutColors() {
    let navigationBarAppearence = UINavigationBarAppearance()
    navigationBarAppearence.configureWithDefaultBackground()
    navigationBarAppearence.backgroundImage = UIImage(named: "RequiLi")
    navigationBarAppearence.backgroundColor = UIColor(named: "NavigationBarColor")
    
    
    
    
    navigationItem.standardAppearance = navigationBarAppearence
    navigationItem.compactAppearance = navigationBarAppearence
    navigationItem.scrollEdgeAppearance = navigationBarAppearence
    navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "BackgroundColor")
    navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "BackgroundColor")
    
    
  
    
    tableView.backgroundView = UIImageView(image: UIImage(named: "BackgroundImage"))
    tableView.backgroundColor?.withAlphaComponent(0)
    
    
  }
}

// MARK: uncategorized function
extension AddNewItemViewController {
  func showUI(_for: PHAuthorizationStatus) {
    switch _for {
    case .notDetermined:
      showAccessDeniedUI()
    case .restricted:
      showAccessDeniedUI()
    case .denied:
      break
    case .authorized:
      showAccessDeniedUI()
    case .limited:
      showAccessDeniedUI()
    }
  }
  
  func gotoAppPrivacySettings() {
      guard let url = URL(string: UIApplication.openSettingsURLString),
          UIApplication.shared.canOpenURL(url) else {
              assertionFailure("Not able to open App privacy settings")
              return
      }

      UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
  
  func showAccessDeniedUI() {
    selectImageButton.isHidden = false
//    selectImageButton.titleLabel?.text = "Access denied to photos."
  }
  
}

// MARK: TableView Data Source
extension AddNewItemViewController {
  
}























