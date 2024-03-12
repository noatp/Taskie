//
//  UIViewExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/11/24.
//

import UIKit

extension UIView {
    func roundTopCorners(cornerRadius: CGFloat) {
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = UIBezierPath(roundedRect: bounds,
                                      byRoundingCorners: [.topLeft, .topRight],
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        
        layer.mask = maskLayer
    }
    
    static func createSpacerView(height: CGFloat? = nil, width: CGFloat? = nil) -> UIView {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        
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
}
