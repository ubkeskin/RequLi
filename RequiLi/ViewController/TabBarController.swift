//
//  CustomTabBarController.swift
//  RequiLi
//
//  Created by OS on 26.08.2022.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

  enum tabBarMenu: Int {
    case home
    case list
  }

  // MARK: UITabBarController


  override func viewDidLoad() {

    super.viewDidLoad()
    
    //change text under
    
    UIBarItem.appearance().setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
    UIBarItem.appearance().setTitleTextAttributes([.foregroundColor : UIColor.white], for: .normal)
        
        //store every image in a variable
    let homeUnselectedImage: UIImage = UIImage(systemName: "house")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    
    let homeSelectedImage: UIImage = UIImage(systemName: "house.fill")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
    let userUnselectedImage: UIImage = UIImage(systemName: "tray")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    let userSelectedImage: UIImage = UIImage(systemName: "tray.fill")!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        
        
        //use that variable for each icon
      tabBar.items![0].image = homeUnselectedImage.withTintColor(.white)
    tabBar.items![0].setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
   
    tabBar.items![0].selectedImage = homeSelectedImage.withTintColor(UIColor(named: "BackgroundColor")!)
      tabBar.items![1].image = userUnselectedImage.withTintColor(.white)

    tabBar.items![1].selectedImage = userSelectedImage.withTintColor(UIColor(named: "BackgroundColor")!)

  }

}
