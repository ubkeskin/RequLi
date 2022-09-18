//
//  BundleUpdate.swift
//  RequiLi
//
//  Created by OS on 18.09.2022.
//

import Foundation


protocol BundleUpdate {
  
  func updateSeedData() 
  
  func copyFiles(from source: String, to destination: String)
}
