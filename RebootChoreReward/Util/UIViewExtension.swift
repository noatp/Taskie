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
}
