//
//  UIViewControllerPreviewWrapper.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import SwiftUI
import UIKit

struct UIViewControllerPreviewWrapper<ViewController: UIViewController>: UIViewControllerRepresentable {
    let makeViewController: () -> ViewController
    let updateViewController: (ViewController, UIViewControllerRepresentableContext<Self>) -> Void
    
    init(makeViewController: @escaping () -> ViewController,
         updateViewController: @escaping (ViewController, UIViewControllerRepresentableContext<Self>) -> Void = { _, _ in }) {
        self.makeViewController = makeViewController
        self.updateViewController = updateViewController
    }

    func makeUIViewController(context: Context) -> ViewController {
        makeViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        updateViewController(uiViewController, context)
    }
}
