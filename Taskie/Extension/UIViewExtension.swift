//
//  UIViewExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/11/24.
//

import UIKit

extension UIView {
    static func createSpacerView(height: CGFloat? = nil, width: CGFloat? = nil) -> UIView {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        
        if height == nil && width == nil {
//            let heightConstraint = spacerView.heightAnchor.constraint(equalToConstant: 0)
//            heightConstraint.priority = UILayoutPriority(1)
//            heightConstraint.isActive = true
            return spacerView
        }
        
        if let height = height {
            NSLayoutConstraint.activate([
                spacerView.heightAnchor.constraint(equalToConstant: height)
            ])
        }
        
        if let width = width {
            NSLayoutConstraint.activate([
                spacerView.widthAnchor.constraint(equalToConstant: width)
            ])
        }
        return spacerView
    }
    
    static func createSeparatorView() -> UIView {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = ThemeManager.shared.currentTheme.color.dividerColor
        
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return separatorView
    }
}
