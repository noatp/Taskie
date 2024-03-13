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
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = StringConstant.currencySymbol
        
        if let amount = Double(self),
           let formattedString = formatter.string(from: NSNumber(value: amount)) {
            return formattedString
        }
        else {
            LogUtil.log("cannot format amount to cents")
            return "x.xx"
        }
    }
}
