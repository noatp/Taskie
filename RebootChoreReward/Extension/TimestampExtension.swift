//
//  TimestampExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/22/24.
//

import Foundation
import FirebaseFirestore

extension Timestamp {
    func toRelativeString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 1
        
        let now = Date()
        let date = self.dateValue()
        let interval = now.timeIntervalSince(date)
        
        if let formattedString = formatter.string(from: interval) {
            return "\(formattedString) ago"
        } else {
            return "Just now"
        }
    }
}
