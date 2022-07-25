//
//  Item+CoreDataProperties.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//
//

import Foundation
import CoreData


extension ItemModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemModel> {
        return NSFetchRequest<ItemModel>(entityName: "ItemModel")
    }

    @NSManaged public var name: String?
    @NSManaged public var category: String?
    @NSManaged public var enerjyValue: Int32
    @NSManaged public var attribute: Data?

}

extension ItemModel : Identifiable {

  var itemCategory: ItemCategory {
    get {
      ItemCategory(rawValue: category!) ?? .undefined
    }
    set {
      category = newValue.rawValue
    }
  }
}

enum ItemCategory: String, CaseIterable {
  case fruit = "Fruit"
  case meat = "Meat"
  case fish = "Fish"
  case vegetable = "Vegetable"
  case junk = "Junk"
  case cleaner = "Cleaner"
  case personalCarePruducts = "Personal Care Pruduct"
  case undefined = "Undefined"
}
