//
//  NSObjectExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/13/24.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
