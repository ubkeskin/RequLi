//
//  PurchasedItemsViewController.swift
//  RequiLi
//
//  Created by OS on 10.08.2022.
//

import Foundation
import CoreData
import UIKit

class PurchasedItemsViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var dataSource: UICollectionViewDiffableDataSource<ItemCategory, ItemModel>?


  var context: NSManagedObjectContext?
  var objectForSelectedCell: NSManagedObject?
  var itemModel: [ItemModel]{
    (objectForSelectedCell as? PurchasedThingsModel)!.items.map { item in
      item
    }
  }
  

  
  lazy var fetchedResultsController: NSFetchedResultsController<PurchasedThingsModel>? = {
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    collectionView.collectionViewLayout = configureLayout()
    configureDataSource()
    configureSnapshot()
  }
  
  func initFetchResultController() {
    guard let fetchedResultsController = fetchedResultsController else {
      return
    }

    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Core Data fetch error")
    }
  }
}

//MARK: Extension Collection View Layout Provider
extension PurchasedItemsViewController{
  func configureLayout() -> UICollectionViewCompositionalLayout {
    let sectionProvider = {(sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
      let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

      
      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(0.3))
      let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
      
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPaging
      section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
      section.interGroupSpacing = 10
      
      let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
      let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
      section.boundarySupplementaryItems = [sectionHeader]
      
      return section
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
}

// MARK: -CollectionViewDataSource

extension PurchasedItemsViewController {
  typealias itemsDataSource =  UICollectionViewDiffableDataSource<ItemCategory, ItemModel>
  
  func configureDataSource() {
    
    
    dataSource = itemsDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item -> UICollectionViewCell? in
      
//      guard let object = self.objectForSelectedCell as? PurchasedThingsModel else {
//        fatalError("object cannot initialized")
//      }
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {fatalError("cell did not dequeued.")}
      
      
      cell.titleLabel.text = item.name
      guard let imageData = item.attribute else {
        return cell
      }
      cell.compactImageView.image = UIImage(data: imageData)

      return cell
    })
    
    dataSource?.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
      
      if let self = self, let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView {
        
        let itemCategory = self.dataSource?.sectionIdentifier(for: indexPath.section)?.info
        titleSupplementaryView.textLabel.text = itemCategory
        
        return titleSupplementaryView
      } else {
        return nil
      }
    }

    collectionView.dataSource = dataSource
  }
  
  func configureSnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<ItemCategory, ItemModel>()
    itemModel.forEach { item in
      if !snapshot.sectionIdentifiers.contains(where: { category in
        item.itemCategory == category
      })
      {
        snapshot.appendSections([item.itemCategory])
        snapshot.appendItems([item])

      } else {
        snapshot.appendItems([item])
      }
    }
    print("snapshot last", snapshot.itemIdentifiers.count)
    dataSource?.apply(snapshot)
  }
  
}
    



//MARK: Fetch Result Controller Delegate
extension PurchasedItemsViewController: NSFetchedResultsControllerDelegate {
//  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
//    let mySnapshot = snapshot as NSDiffableDataSourceSnapshot<String,NSManagedObject>
//    dataSource?.apply(mySnapshot)
//  }
}
