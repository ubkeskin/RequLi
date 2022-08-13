//
//  Item+CoreDataClass.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//
//

import Foundation
import CoreData

@objc(ItemModel)
public class ItemModel: NSManagedObject {
  init(name: String,
       category: Double,
       enerjyValue: Int32,
       attribute: Data?,
       purchasedThingsList: Set<PurchasedThingsModel>?,
       context: NSManagedObjectContext) {
      let entity = NSEntityDescription.entity(forEntityName: "ItemModel", in: context)!
      super.init(entity: entity, insertInto: context)
      self.name = name
      self.category = category
      self.enerjyValue = enerjyValue
      self.attribute = attribute
      self.purchasedThingsList = purchasedThingsList
  }
  
  public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
      super.init(entity: entity, insertInto: context)
  }
}
