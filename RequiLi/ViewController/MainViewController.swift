//
//  ViewController.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
  
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  private var dataSource: UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID>!
  private var sections: [ItemCategory] = []

  var context: NSManagedObjectContext!
  
  private lazy var fetchedResultsController: NSFetchedResultsController<ItemModel>? = {
    
  let fetchRequest: NSFetchRequest<ItemModel> = ItemModel.fetchRequest()
  let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
  fetchRequest.sortDescriptors = [sortDescriptor]

  
  let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                       managedObjectContext: context,
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
    guard let fetchedResultsController = fetchedResultsController else {
      return
    }

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
    collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    collectionView.collectionViewLayout = configureLayout()
    collectionView.delegate = self
    configureDataSource()
    initFetchResultController()

//    initialSnapshot()

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

extension MainViewController {
  typealias itemsDataSource =  UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID>
  func configureDataSource() {
    
    guard let context = self.context else { return }
    dataSource = itemsDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, objectID -> UICollectionViewCell? in
      
      guard let object = self.fetchedResultsController?.managedObjectContext.object(with: objectID) as? ItemModel else {
        fatalError("object cannot initialized")
      }
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {return nil}
//      cell.compactImageView = UIImageView(image: UIImage(systemName: "r.square.fill"))
      cell.titleLabel.text = object.name

      return cell
    })
    
    dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
      
      if let self = self, let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView {
        
        let itemCategory = self.dataSource.sectionIdentifier(for: indexPath.section)?.info
        titleSupplementaryView.textLabel.text = itemCategory
        
        return titleSupplementaryView
      } else {
        return nil
      }
    }

    
    collectionView.dataSource = dataSource
  }
  
}

// MARK: -NS Fetched Results Controller Delegate
extension MainViewController: NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
      guard let dataSource = collectionView?.dataSource as? UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID> else {assertionFailure("The data source has not implemented snapshot support while it should")
        return
    }

      
      var snapshot = snapshot as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>
      var currentSnapshot = dataSource.snapshot() as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>
      
      let reloadIdentifiers: [NSManagedObjectID] = snapshot.itemIdentifiers.compactMap { itemIdentifier in
          guard let currentIndex = currentSnapshot.indexOfItem(itemIdentifier), let index = snapshot.indexOfItem(itemIdentifier), index == currentIndex else {
              return nil
          }
          guard let existingObject = try? controller.managedObjectContext.existingObject(with: itemIdentifier), existingObject.isUpdated else { return nil }
          return itemIdentifier
      }
      snapshot.reloadItems(reloadIdentifiers)
      
      print(snapshot.itemIdentifiers.count)
      print(currentSnapshot.itemIdentifiers.count)

     let appendingItems = snapshot.itemIdentifiers.filter { objectID in
       !currentSnapshot.itemIdentifiers.contains(objectID)
      }
      
      fetchedResultsController?.fetchedObjects?.filter({ item in
        appendingItems.contains(item.objectID)
      }) .forEach({ item in
        if !sections.contains(item.itemCategory) {
          sections.append(item.itemCategory)
          currentSnapshot.appendSections([item.itemCategory])
          currentSnapshot.appendItems([item.objectID], toSection: item.itemCategory)
        } else {
          currentSnapshot.appendItems([item.objectID], toSection: item.itemCategory)
        }
      })
      
      print(snapshot.itemIdentifiers.count)
      print(currentSnapshot.itemIdentifiers.count)
      

      let shouldAnimate = collectionView?.numberOfSections != 0


      self.dataSource.apply(currentSnapshot as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>, animatingDifferences: false)
    }
  

}

// MARK: -Prepare for segue
extension MainViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "AddNewItem": if let controller = (segue.destination as? AddNewItemViewController) {
      handleAddNewItemSegue(newItemViewController: controller)
    }
    default: return
    }
  }
  
  private func handleAddNewItemSegue(newItemViewController: AddNewItemViewController) {
    newItemViewController.context = self.context
  }
  
}

// MARK: -Collection View Delegate

extension MainViewController: UICollectionViewDelegate {

  }



