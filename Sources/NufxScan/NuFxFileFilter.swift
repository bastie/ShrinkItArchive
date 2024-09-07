//
//  File.swift
//  
//
//  Created by Sebastian Ritter on 05.09.24.
//
import JavApi
import Foundation

extension NufxScan {
  internal class NuFxFileFilter : java.io.FileFilter {
    typealias FileFilter = NuFxFileFilter
    
    public func accept(_ file : java.io.File) -> Bool {
      let isSHK : Bool = file.getName().toLowerCase().endsWith(".shk");
      let isSDK : Bool = file.getName().toLowerCase().endsWith(".sdk");
      let isDirectory : Bool = file.isDirectory();
      let keep = isSHK || isSDK || isDirectory;
      return keep;
    }
  }
}
