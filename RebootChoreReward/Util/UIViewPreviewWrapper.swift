//
//  UIViewPreviewWrapper.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import SwiftUI

struct UIViewPreviewWrapper<View: UIView>: UIViewRepresentable {
    let makeView: () -> View
    
    init(_ makeView: @escaping () -> View) {
        self.makeView = makeView
    }
    
    func makeUIView(context: Context) -> View {
        makeView()
    }
    
    func updateUIView(_ uiView: View, context: Context) {
        // Perform any updates to the UI view if necessary.
    }
}
