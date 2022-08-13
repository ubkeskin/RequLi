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
  private var barButton: UIBarButtonItem?
  private var sections: [ItemCategory] = []
  private var selectedItemIdentifiers: [NSManagedObjectID] = []
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
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    barButton = navigationItem.leftBarButtonItem

    setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    initFetchResultController()
  }
  
  func setupView() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBarItem), name: .selectedIdentifiersUpdated, object: nil)
    updateNavigationBarItem(notificaition: .init(name: .selectedIdentifiersUpdated))
    collectionView.register(TitleSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)
    collectionView.collectionViewLayout = configureLayout()
    collectionView.delegate = self
    configureDataSource()
//    initFetchResultController()


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
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {fatalError("cell did not dequeued.")}
      cell.titleLabel.text = object.name
      guard let imageData = object.attribute else {
        return cell
      }
      cell.compactImageView.image = UIImage(data: imageData)

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

      
      let snapshot = snapshot as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>
      var currentSnapshot = NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>()
      
  

      
      snapshot.itemIdentifiers.forEach { objectID in
        var item = controller.managedObjectContext.object(with: objectID) as? ItemModel
        if !currentSnapshot.sectionIdentifiers.contains(item!.itemCategory) {
        currentSnapshot.appendSections([item!.itemCategory])
        currentSnapshot.appendItems([item!.objectID], toSection: item?.itemCategory)
        } else {
          currentSnapshot.appendItems([item!.objectID], toSection: item?.itemCategory)

        }
      }
      
      print("snapshot",snapshot.itemIdentifiers.count)
      print("currentSnapshot", currentSnapshot.itemIdentifiers.count)

      let shouldAnimate = dataSource.snapshot().numberOfItems - currentSnapshot.numberOfItems != 0


      self.dataSource.apply(currentSnapshot as NSDiffableDataSourceSnapshot<ItemCategory, NSManagedObjectID>, animatingDifferences: shouldAnimate)
    }
  

}

// MARK: -Prepare for segue
extension MainViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "AddNewItem": if let controller = (segue.destination as? AddNewItemViewController) {
      handleAddNewItemSegue(newItemViewController: controller)
    }
    case "SaveSelectedItems": if let controller = (segue.destination as? SelectedItemsViewController) {
      handleSelectedItemsSegue(selectedItemsViewController: controller)
    }
    default: return
    }
  }
  
  private func handleAddNewItemSegue(newItemViewController: AddNewItemViewController) {
    newItemViewController.context = self.context
  }
  private func handleSelectedItemsSegue(selectedItemsViewController: SelectedItemsViewController) {
    selectedItemsViewController.context = self.context
    selectedItemsViewController.selectedItemIdentifiers = selectedItemIdentifiers
  }

  
}

// MARK: -Collection View Delegate

extension MainViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    updateSelectedIdentifiers(collectionView: collectionView, indexPath: indexPath)
    }
  
  @objc func updateSelectedIdentifiers(collectionView: UICollectionView, indexPath: IndexPath) {
    
    guard let indexPathForItemIdentifier = collectionView.dataSourceIndexPath(forPresentationIndexPath: indexPath) else { return }
    guard let selectedItemIdentifier = dataSource.itemIdentifier(for: indexPathForItemIdentifier) else { return }
    guard let cell = collectionView.cellForItem(at: indexPath) as? ItemCell else {
      return
    }
    if !selectedItemIdentifiers.contains(selectedItemIdentifier) {
      
      selectedItemIdentifiers.append(selectedItemIdentifier)
      cell.checkMark.image = UIImage(systemName: "circle.fill")!
    } else {
      selectedItemIdentifiers.removeAll { objectID in
        objectID == selectedItemIdentifier
      }
      cell.checkMark.image = UIImage(systemName: "circle")!
    }
    NotificationCenter.default.post(name: .selectedIdentifiersUpdated, object: nil)

  }
  
  @objc func updateNavigationBarItem(notificaition: Notification) {
    if selectedItemIdentifiers.count > 0 {
      navigationItem.setLeftBarButton(barButton, animated:{
        selectedItemIdentifiers.count > 1 ? false : true
      }() )
      }
     else {
       navigationItem.setLeftBarButton(nil, animated: true)
    }
    
  }
  
  
  
}




