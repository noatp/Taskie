//
//  DoubleExtension.swift
//  Taskie
//
//  Created by Toan Pham on 6/3/24.
//

import Foundation

extension Double {
    func formattedToTwoDecimalPlaces() -> String {
        return String(format: "%.2f", self)
    }
}
