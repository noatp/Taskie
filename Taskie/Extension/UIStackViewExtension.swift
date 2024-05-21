//
//  UIStackViewExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/25/24.
//

import UIKit

extension UIStackView {
    static func vStack(arrangedSubviews: [UIView], alignment: Alignment, shouldExpandSubviewWidth: Bool = false) -> UIStackView{
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .vertical
        stackView.alignment = alignment
        stackView.spacing = 0
        
        if shouldExpandSubviewWidth {
            for subview in arrangedSubviews {
                subview.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
            }
        }
        return stackView
    }
    
    static func hStack(arrangedSubviews: [UIView], alignment: Alignment, shouldExpandSubviewHeight: Bool = false) -> UIStackView{
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.alignment = alignment
        stackView.spacing = 0
        
        if shouldExpandSubviewHeight {
            for subview in arrangedSubviews {
                subview.heightAnchor.constraint(equalTo: stackView.heightAnchor, multiplier: 1).isActive = true
            }
        }
        return stackView
    }
}
