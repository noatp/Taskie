//
//  LogUtil.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//


import Foundation

struct LogUtil {
    static func log(_ msg: String, file: String = #fileID, function: String = #function) {
        let fileName = extractFileName(from: file)
        print("\(fileName) \(function): \(msg)")
    }
    
    static func extractFileName(from filePath: String) -> String {

        let components = filePath.split(separator: "/").last ?? ""
        

        let fileNameWithExtension = String(components)
        

        let fileName = fileNameWithExtension.replacingOccurrences(of: ".swift", with: "")
        
        return fileName
    }
}
