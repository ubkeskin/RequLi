//
//  AppDelegate.swift
//  RequiLi
//
//  Created by OS on 22.07.2022.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    seedData()
    UITabBar.appearance().unselectedItemTintColor = UIColor.green
    

    return true
  }
  
  func seedData() {
    let fileManager = FileManager.default
    let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
    let destinationFolder = libraryDirectory.appendingPathComponent("Application Support").path
    
    let folderPath = Bundle.main.resourceURL!.appendingPathComponent("RequiLiSeedData").path
    
    let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    if let applicationSupportUrl = urls.last{
      do {
        try fileManager.createDirectory(at: applicationSupportUrl, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print(error)
      }
    }
    copyFiles(pathFromBundle: folderPath, pathDestDocs: destinationFolder)
    
  }
  
  func copyFiles(pathFromBundle: String, pathDestDocs: String) {
    let fileManager = FileManager.default
    
    do {
      let fileList = try fileManager.contentsOfDirectory(atPath: pathFromBundle)
      let fileDestinationList = try fileManager.contentsOfDirectory(atPath: pathDestDocs)
      
      for fileName in fileDestinationList {
        try fileManager.removeItem(atPath: "\(pathDestDocs)/\(fileName)")
      }
      for fileName in fileList {
        try fileManager.copyItem(atPath: "\(pathFromBundle)/\(fileName)", toPath: "\(pathDestDocs)/\(fileName)")
      }
    } catch  {
      print(error)
    }
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
  

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {

      let container = NSPersistentContainer(name: "RequiLi")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {

              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
  }()
  

  // MARK: - Core Data Saving support

  func saveContext () {
    let context = persistentContainer.viewContext
      if context.hasChanges {
          do {
              try context.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
      }
  }

}

