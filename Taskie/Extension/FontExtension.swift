//
//  FontExtension.swift
//  Taskie
//
//  Created by Toan Pham on 6/15/24.
//

import SwiftUI
import UIKit

extension Font {
    static func from(uiFont: UIFont) -> Font {
        return Font(uiFont as CTFont)
    }
}
