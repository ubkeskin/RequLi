//
//  ViewController.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//

import UIKit
import CoreData

class MainViewController: UIViewController, BundleUpdate {
  
  
  @IBOutlet var addNewItemButton: UIBarButtonItem!
  @IBOutlet var deleteButton: UIBarButtonItem!
  @IBOutlet var backgroundView: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBAction func prepareForUnwindCancelButton(segue: UIStoryboardSegue) {
    guard let source = segue.source as? SelectedItemsViewController else {
    return
    }
    guard let destination = segue.destination as? MainViewController else {
      return
    }
    selectedItemIdentifiers = source.selectedItemIdentifiers.count == 0 ? [] : source.selectedItemIdentifiers
    destination.configureNavigationAndTabBars()
    updateNavigationBarItem(notificaition: Notification(name: .selectedIdentifiersUpdated))
  }
  @IBAction func prepareForUnwindSaveButton(segue: UIStoryboardSegue) {
    guard let source = segue.source as? SelectedItemsViewController else {
    return
    }
    guard let destination = segue.destination as? MainViewController else {
      return
    }
    selectedItemIdentifiers = []
    destination.configureNavigationAndTabBars()
    updateNavigationBarItem(notificaition: Notification(name: .selectedIdentifiersUpdated))
    
    self.tabBarController?.selectedIndex = 1
  }
  
  private var dataSource: UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID>!
  
    
  @IBOutlet var saveSelectedItemsBarButton: UIButton!
  @IBOutlet var leftBarButtonItem: UIBarButtonItem!
  
  private var sections: [ItemCategory] = []
  private var selectedItemIdentifiers: [NSManagedObjectID] = []
  var context: NSManagedObjectContext!
  
  private lazy var fetchedResultsController: NSFetchedResultsController<ItemModel>? = {
  
    guard let context = self.context
      else {
        return nil
      }
    
    
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
    setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    tabBarController?.tabBar.isHidden = false
    initFetchResultController()
  }
  
  override func setEditing(_ editing: Bool, animated: Bool) {
    super.setEditing(editing, animated: animated)
    
    navigationItem.setRightBarButtonItems([deleteButton, addNewItemButton], animated: true)
    
    collectionView.allowsMultipleSelection = true
    collectionView.indexPathsForVisibleItems.forEach {
      guard let itemCell = collectionView.cellForItem(at: $0) as? ItemCell else { return }
      itemCell.isEditing = editing
    }
    
    if !isEditing {
      navigationItem.setRightBarButtonItems(nil, animated: true)
      
      collectionView.allowsMultipleSelection = false
      collectionView.indexPathsForSelectedItems?.compactMap({ $0 }).forEach {
        collectionView.deselectItem(at: $0, animated: true)
      }
    }
  }
  
  func updateSeedData() {
    let fileManager = FileManager.default
    let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
    let sourceFolder = libraryDirectory!.appendingPathComponent("Application Support").path
    
    let destination = Bundle.main.resourceURL!.appendingPathComponent("RequiLiSeedData").path
    
    copyFiles(from: sourceFolder, to: destination)
    }
  
  func copyFiles(from source: String, to destination: String) {
    let fileManager = FileManager.default
    
    do {
      let fileList = try fileManager.contentsOfDirectory(atPath: source)
      let fileDestinationList = try fileManager.contentsOfDirectory(atPath: destination)
      
      for fileName in fileDestinationList {
        try fileManager.removeItem(atPath: "\(destination)/\(fileName)")
      }
      for fileName in fileList {
        try fileManager.copyItem(atPath: "\(source)/\(fileName)", toPath: "\(destination)/\(fileName)")
      }
    } catch  {
      print(error)
    }
  }
  
  func setupView() {

    leftBarButtonItem = navigationItem.leftBarButtonItem
    navigationItem.setRightBarButtonItems(nil, animated: false)
    navigationItem.leftBarButtonItem = editButtonItem
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBarItem), name: .selectedIdentifiersUpdated, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(updateTitleSupplementaryView), name: .titleSupplementeryViewBackgroundUpdated, object: nil)
    
    collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 10)
    
    print(NSHomeDirectory())
    
    configureNavigationAndTabBars()
    updateNavigationBarItem(notificaition: .init(name: .selectedIdentifiersUpdated))
    collectionView.collectionViewLayout = configureLayout()
    collectionView.delegate = self
    configureDataSource()
  }
  
  @IBAction func deleteItem(_ sender: Any) {
    guard let selectedIndices = collectionView.indexPathsForSelectedItems else { return }
    let dataSourceIndices = selectedIndices.compactMap({ path in
      collectionView.dataSourceIndexPath(forPresentationIndexPath: path)
    })
    let dataSourceIdentifiers = dataSourceIndices.compactMap { path in
      dataSource.itemIdentifier(for: path)
    }
    
      dataSourceIdentifiers.forEach { id in
        context.delete(context.object(with: id))
      }
      do {
        try context?.save()
        dismiss(animated: true)
      } catch {
        fatalError("core data save error")
      }
      updateSeedData()
    }
}
// MARK: -Collection View
  extension MainViewController {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == "background"{
                let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "BackgroundReusableView", for: indexPath) as! BackgroundReusableView
              
              view.backgroundImage?.image = UIImage(named: "BackgroundImage")
                return view
            }
            return UICollectionReusableView()
        }
    
    func configureLayout() -> UICollectionViewCompositionalLayout  {
        
      
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
          
          let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
          let item = NSCollectionLayoutItem(layoutSize: itemSize)
          item.contentInsets = NSDirectionalEdgeInsets(top: 25, leading: 5, bottom: 20, trailing: 5)
          
          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.32), heightDimension: .fractionalHeight(0.23))
          let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
          group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
          
          
          let section = NSCollectionLayoutSection(group: group)
          section.orthogonalScrollingBehavior = .continuous
          section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0)
          section.interGroupSpacing = 0
          
          
          
          let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
          let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
          sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 30, leading: 10, bottom: 0, trailing: 10)
          
          section.boundarySupplementaryItems = [sectionHeader]
          
        
          
          return section
        }
      
      let customLayout = CustomCompositionalLayout(sectionProvider: sectionProvider)
      
      collectionView.collectionViewLayout = customLayout

        return customLayout
      }
    
    class CustomCompositionalLayout: UICollectionViewCompositionalLayout {
    }
    }

// MARK: -CollectionViewDataSource

extension MainViewController {
  typealias itemsDataSource =  UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID>
  func configureDataSource() {
    
    guard let context = self.context else { return }
    dataSource = itemsDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, objectID -> UICollectionViewCell? in
      
      guard let object = context.object(with: objectID) as? ItemModel else {
        fatalError("object cannot initialized")
      }
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? ItemCell else {fatalError("cell did not dequeued.")}
      cell.titleLabel.text = object.name?.uppercased()
      cell.titleLabel.textColor = UIColor(named: "TextColor")
      
      
      
      guard let imageData = object.attribute else {
        return cell
      }
      cell.compactImageView.image = UIImage(data: imageData)
      cell.layer.cornerRadius = 20
      
      
//      cell.backgroundColor = UIColor(named: "LabelBackgroundColor")
      
      if self.selectedItemIdentifiers.contains(objectID) {
        cell.backgroundColor = UIColor(named: "BackgroundColor")
      } else {
        cell.backgroundColor = .white
        
      }

      
      return cell
    })
    
    dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
      
      if let self = self {
        guard let titleSupplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as? TitleSupplementaryView else {
          return nil
        }

          
        let itemCategory = self.dataSource.sectionIdentifier(for: indexPath.section)?.info
          titleSupplementaryView.textLabel?.text = itemCategory
//          titleSupplementaryView.backgroundImage?.image = UIImage(named: itemCategory!)
          titleSupplementaryView.textLabel?.textColor = UIColor(named: "TextColor")
          titleSupplementaryView.textLabel?.backgroundColor = UIColor(named: "default")
          titleSupplementaryView.backgroundColor = UIColor() {_ in
          var sectionSelected: Bool = false
            if let section = self.dataSource.sectionIdentifier(for: indexPath.section) {
              let objects: [ItemModel] = self.selectedItemIdentifiers.compactMap { id in
                (context.object(with: id) as? ItemModel)
              }
              let sectionsOfObjects = objects.map { model in
                model.itemCategory
              }
              if sectionsOfObjects.contains(section) {
                sectionSelected = true
              } else {
                sectionSelected = false
              }
            }
            if sectionSelected {
              return UIColor(named: "BackgroundColor")!
            } else {
              return UIColor(named: "TitleSubviewBackgroundColor")!
            }
        }
          titleSupplementaryView.layer.cornerRadius = 20
        return titleSupplementaryView
        
        
      } else {
        return nil
      }
    }
    collectionView.dataSource = self.dataSource
    
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
        let item = controller.managedObjectContext.object(with: objectID) as? ItemModel
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
    if !isEditing {
      updateSelectedIdentifiers(collectionView: collectionView, indexPath: indexPath)
    }
    }
  
  @objc func updateSelectedIdentifiers(collectionView: UICollectionView, indexPath: IndexPath) {
    
    guard let indexPathForItemIdentifier = collectionView.dataSourceIndexPath(forPresentationIndexPath: indexPath) else { return }
    guard let selectedItemIdentifier = dataSource.itemIdentifier(for: indexPathForItemIdentifier) else { return }
    guard let selectedObject = context.object(with: selectedItemIdentifier) as? ItemModel else { return }
    guard let cell = collectionView.cellForItem(at: indexPath) as? ItemCell else {
      return
    }
    let sectionsForSelectedIDs = selectedItemIdentifiers.map { id in
      context.object(with: id) as? ItemModel
    }.map { model in
      model?.itemCategory
    }
    
    if !selectedItemIdentifiers.contains(selectedItemIdentifier) {
      
      selectedItemIdentifiers.append(selectedItemIdentifier)
//      cell.checkMark.image = UIImage(systemName: "rectangle.fill")!
      cell.backgroundColor = UIColor(named: "BackgroundColor")

    } else {
      selectedItemIdentifiers.removeAll { objectID in
        objectID == selectedItemIdentifier
      }
      cell.backgroundColor = .white
    }
    
    NotificationCenter.default.post(name: .selectedIdentifiersUpdated, object: nil)
    let newSectionsForSelectedIDs = selectedItemIdentifiers.map { id in
      context.object(with: id) as? ItemModel
    }.map { model in
      model?.itemCategory
    }
    
    if sectionsForSelectedIDs.count != newSectionsForSelectedIDs.count{
      NotificationCenter.default.post(name: .titleSupplementeryViewBackgroundUpdated, object: nil)
    }

  }
  
  func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
    true
  }
  
  func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
    collectionView.isEditing = true
  }
  
  func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
    collectionView.isEditing = false
  }

}

//MARK: Extensions

extension MainViewController {
  
  
  @objc func updateNavigationBarItem(notificaition: Notification) {
    if selectedItemIdentifiers.count > 0 {
      
      var badge = BadgeLabelView(frame: CGRect(x: 15, y: 0, width: 15, height: 15))
      badge.text = String(describing: selectedItemIdentifiers.count)
      saveSelectedItemsBarButton.addSubview(badge)
      navigationItem.setLeftBarButton(leftBarButtonItem, animated:{
        selectedItemIdentifiers.count > 1 ? false : true
      }() )
      
      }
     else {
       navigationItem.setLeftBarButton(editButtonItem, animated: true)
    }
    
  }
  @objc func updateTitleSupplementaryView()  {
    collectionView.reloadData()
  }
  
  func configureNavigationAndTabBars() {
    let navigationBarAppearence = UINavigationBarAppearance()
    navigationBarAppearence.configureWithDefaultBackground()
    navigationBarAppearence.backgroundImage = UIImage(named: "RequiLi")
    navigationBarAppearence.backgroundColor = UIColor(named: "NavigationBarColor")
    
    
    navigationBarAppearence.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    
    navigationItem.standardAppearance = navigationBarAppearence
    navigationItem.compactAppearance = navigationBarAppearence
    navigationItem.scrollEdgeAppearance = navigationBarAppearence
    
    navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "TextColor")
    navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "TextColor")
    
    var appearence = UITabBarAppearance()
    appearence.backgroundImage = UIImage(named: "BackgroundImage")
    
    tabBarController?.tabBar.standardAppearance = appearence
    tabBarController?.tabBar.scrollEdgeAppearance = appearence
    
    
    backgroundView.image = UIImage(named: "BackgroundImage")
    
    backgroundView.translatesAutoresizingMaskIntoConstraints = false 
    
    NSLayoutConstraint.activate([
      backgroundView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: 10),
      backgroundView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor , constant: 10),
      backgroundView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor, constant: 10),
      backgroundView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: 10),
            ])
  
  }
}








