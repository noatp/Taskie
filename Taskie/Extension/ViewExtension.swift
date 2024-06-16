//
//  ViewExtension.swift
//  Taskie
//
//  Created by Toan Pham on 6/15/24.
//

import SwiftUI

extension View {
    func applyTheme() -> some View {
        self.modifier(ThemedViewModifier())
    }
}
