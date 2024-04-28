//
//  PDSLoadingIndicator.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/28/24.
//

import UIKit
import SwiftUI

class PDSLoadingIndicator: UIViewController {
    private let backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    private func setUpViews() {
        ThemeManager.shared.register(self)
        
        view.addSubview(backgroundView)
        backgroundView.contentView.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        spinner.startAnimating()
    }
}

extension PDSLoadingIndicator: Themable {
    func applyTheme(_ theme: PDSTheme) {
        spinner.color = theme.color.secondaryColor
    }
}

struct PDSLoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Text("Background Content") // Changed from Label to Text for simplicity
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green)
            UIViewControllerPreviewWrapper {
                PDSLoadingIndicator()
            }
        }
        
    }
}
