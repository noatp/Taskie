//
//  StringExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/12/24.
//

import Foundation

extension String {
    func stripDollarSign() -> String {
        return self.replacingOccurrences(of: StringConstant.currencySymbol, with: StringConstant.emptyString).trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func formatAmountInCents() -> String {
        if let amount = Double(self) {
            return String(format: "%.2f", amount)
        } else {
            LogUtil.log("Cannot format amount to cents")
            return "0.00"
        }
    }
}
    
