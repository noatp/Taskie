//
//  LogUtil.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//


import Foundation

struct LogUtil {
    static func log(_ msg: String, file: String = #fileID, function: String = #function) {
        print("\(file) \(function): \(msg)")
    }
}
