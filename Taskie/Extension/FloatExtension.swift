//
//  FloatExtension.swift
//  Taskie
//
//  Created by Toan Pham on 7/6/24.
//

import Foundation

extension Float {
    func formattedToTwoDecimalPlaces() -> String {
        return String(format: "%.2f", self)
    }
}
