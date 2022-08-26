//
//  ViewController.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
  
  
  @IBOutlet var backgroundView: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBAction func prepareForUnwindCancelButton(segue: UIStoryboardSegue) {
    guard let source = segue.source as? SelectedItemsViewController else {
    return
    }
    selectedItemIdentifiers = source.selectedItemIdentifiers
  }
  @IBAction func prepareForUnwindSaveButton(segue: UIStoryboardSegue) {
    guard let source = segue.source as? SelectedItemsViewController else {
    return
    }
    selectedItemIdentifiers = []
    
    self.tabBarController?.selectedIndex = 1
  }
  
  private var dataSource: UICollectionViewDiffableDataSource<ItemCategory, NSManagedObjectID>!
  private var barButton: UIBarButtonItem?
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
    barButton = navigationItem.leftBarButtonItem

    setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    tabBarController?.tabBar.isHidden = false
    initFetchResultController()
  }
  
  func setupView() {
    NotificationCenter.default.addObserver(self, selector: #selector(updateNavigationBarItem), name: .selectedIdentifiersUpdated, object: nil)

    
    configureNavigationAndTabBars()
    updateNavigationBarItem(notificaition: .init(name: .selectedIdentifiersUpdated))
    collectionView.collectionViewLayout = configureLayout()
    collectionView.delegate = self
    configureDataSource()


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
          
          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(0.2))
          let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
          group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
          
          
          let section = NSCollectionLayoutSection(group: group)
          section.orthogonalScrollingBehavior = .continuous
          section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 0)
          section.interGroupSpacing = 0
          
          
          
          let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
          let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
          sectionHeader.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
          
          section.boundarySupplementaryItems = [sectionHeader]
        
          
          return section
        }
      
      let customLayout = CustomCompositionalLayout(sectionProvider: sectionProvider)
      
      collectionView.collectionViewLayout = customLayout

        return customLayout
      }
    
    class CustomCompositionalLayout: UICollectionViewCompositionalLayout {
      override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        
        for section in 0..<collectionView!.numberOfSections {
          let backgroundAttributes = layoutAttributesForSupplementaryView(ofKind: "background", at: IndexPath(item: 0, section: section)) ?? UICollectionViewLayoutAttributes()
          attributes?.append(backgroundAttributes)
        }
        return attributes
      }
      override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)

        if elementKind == "background" {
          attrs.size = collectionViewContentSize
          
          guard let items = collectionView?.numberOfItems(inSection: indexPath.section),
          let cellAttrbts = collectionView!.layoutAttributesForItem(at: indexPath)
          else { return UICollectionViewLayoutAttributes() }
          let totalSectionHeight: CGFloat = CGFloat(items * 600)
          attrs.frame = CGRect(x: 0, y: cellAttrbts.frame.origin.y, width: collectionView!.frame.size.width, height: totalSectionHeight)
          
          attrs.zIndex = -10
          
          return attrs
        }
        else {
          return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
      }
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
          titleSupplementaryView.backgroundImage?.image = UIImage(named: itemCategory!)
          titleSupplementaryView.textLabel?.textColor = UIColor(named: "TextColor")
          titleSupplementaryView.textLabel?.backgroundColor = UIColor(named: "default")
          titleSupplementaryView.backgroundColor = UIColor(named: "LabelBackgroundColor")
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
//      cell.checkMark.image = UIImage(systemName: "rectangle.fill")!
      cell.backgroundColor = UIColor(named: "BackgroundColor")

    } else {
      selectedItemIdentifiers.removeAll { objectID in
        objectID == selectedItemIdentifier
      }
      cell.backgroundColor = .white
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

extension MainViewController {
  func configureNavigationAndTabBars() {
    let navigationBarAppearence = UINavigationBarAppearance()
    navigationBarAppearence.configureWithDefaultBackground()
    navigationBarAppearence.backgroundImage = UIImage(named: "RequiLi")
    navigationBarAppearence.backgroundColor = UIColor(named: "NavigationBarColor")
    
    navigationBarAppearence.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    
    navigationItem.standardAppearance = navigationBarAppearence
    navigationItem.compactAppearance = navigationBarAppearence
    navigationItem.scrollEdgeAppearance = navigationBarAppearence
    
    navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "BackgroundColor")
    navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "BackgroundColor")
    
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








