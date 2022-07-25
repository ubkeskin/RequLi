//
//  ViewController.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//

import UIKit
import CoreData

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate {
  
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var dataSource: UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID>!
  private var context: NSManagedObjectContext!
  
  private lazy var fetchedResultsController: NSFetchedResultsController<ItemModel> = {
    
  let fetchRequest: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
  let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
  fetchRequest.sortDescriptors = [sortDescriptor]
  
  let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: context!,
                                       sectionNameKeyPath: nil,
                                       cacheName: nil)
  frc.delegate = self
  return frc
}()
  
  private var testArray: Array<Int> {
    var array: Array<Int> = []
    for i in 1...100 {
      array.append(i)
    }
    return array
  }
  
  func initFetchResultController() {
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Core Data fetch error")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
//    collectionView.collectionViewLayout = configureLayout()
//    configureDataSource()
//    initFetchResultController()
  }
  
  func setupView() {
    collectionView.register(ItemCell.self, forCellWithReuseIdentifier: ItemCell.reuseIdentifier)
    collectionView.collectionViewLayout = configureLayout()
    configureTestDataSource()
    configureTestSnapshot()

  }
}
// MARK: -Collection View
  extension MainViewController {
    
    func configureLayout() -> UICollectionViewCompositionalLayout  {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
          
          let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
          let item = NSCollectionLayoutItem(layoutSize: itemSize)
          item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
          
          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .fractionalHeight(0.3))
          let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
          
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

extension MainViewController {
  typealias itemsDataSource =  UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID>
  func configureDataSource() {
    dataSource = itemsDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, objectID -> UICollectionViewCell? in
      
      guard let object = try? self.context.existingObject(with: objectID) as? ItemModel else {
        fatalError("Managed object should be available")
      }
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {return nil}
      cell.compactImageView = UIImageView(image: UIImage(systemName: "r.square.fill"))
      cell.label.text = object.name
      
        
      
      return cell
    })
    collectionView.dataSource = dataSource
  }
  func configureTestDataSource() {
    let optionalDataSource = UICollectionViewDiffableDataSource<Int, Int>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
      
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCell.reuseIdentifier, for: indexPath) as? ItemCell else{return nil}
      cell.compactImageView = UIImageView(image: UIImage(systemName: "r.square.fill"))
      cell.label.text = itemIdentifier.description
      
      return cell
    }
    collectionView.dataSource = optionalDataSource
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
    guard let dataSource = collectionView?.dataSource as? UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID> else {assertionFailure("The data source has not implemented snapshot support while it should")
      return
  }
    var snapshot = snapshot as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>
    let currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>
    
    let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
        guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
            return nil
        }
        guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
        return itemIdentifier
    }
    snapshot.reloadItems(reloadIdentifiers)
    let shouldAnimate = collectionView?.numberOfSections != 0
    dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>, animatingDifferences: shouldAnimate)

  }
  
  func configureTestSnapshot() {
    var currentSnapshot = NSDiffableDataSourceSnapshot<Int, Int>()
    currentSnapshot.appendSections([1])
    currentSnapshot.appendItems(testArray)

  }
}

// MARK: -Collection View Delegate

extension MainViewController: UICollectionViewDelegate {
 
}



