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
    @NSManaged public var category: Double
    @NSManaged public var enerjyValue: Int32
    @NSManaged public var attribute: Data?
    @NSManaged public var purchasedThingsList: Set<PurchasedThingsModel>?


}

extension ItemModel : Identifiable {

  var itemCategory: ItemCategory {
    get {
      ItemCategory(rawValue: category) ?? .undefined
    }
    set {
      category = newValue.rawValue
    }
  }
}

enum ItemCategory: Double, CaseIterable, Hashable {
  
  case fruit = 0.0
  case meat = 1.0
  case fish = 2.0
  case vegetable = 3.0
  case junk = 4.0
  case cleaner = 5.0
  case personalCarePruducts = 6.0
  case undefined = 7.0
  
  var info: String {
    switch self {
    case .fruit: return "Fruit"
    case .meat: return "Meat"
    case .fish: return "Fish"
    case .vegetable: return "Vegetable"
    case .junk: return "Junk"
    case .cleaner: return "Cleaner"
    case .personalCarePruducts: return "Peronal Care Product"
    case .undefined: return "Undefined"
    }
    
  }
}
