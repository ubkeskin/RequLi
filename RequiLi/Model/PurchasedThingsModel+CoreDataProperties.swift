//
//  PurchasedThingsModel+CoreDataProperties.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//
//

import Foundation
import CoreData


extension PurchasedThingsModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PurchasedThingsModel> {
        return NSFetchRequest<PurchasedThingsModel>(entityName: "PurchasedThingsModel")
    }

    @NSManaged public var date: Date?
    @NSManaged public var cost: Double
    @NSManaged public var items: Set<ItemModel>

}

// MARK: Generated accessors for items
extension PurchasedThingsModel {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ItemModel)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ItemModel)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension PurchasedThingsModel : Identifiable {

}
