//
//  PDSTextField.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class PDSTextField: UITextField, Themable {
    // Define the colors for normal and highlighted states
    var normalBorderColor = UIColor.gray.cgColor
    var highlightedBorderColor = UIColor.systemBlue.cgColor
    
    // Define the border width for normal and highlighted states
    let normalBorderWidth: CGFloat = 1.0
    let highlightedBorderWidth: CGFloat = 3.0
    
    var textPadding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        ThemeManager.shared.register(self)
        // Initial border setup
        layer.borderColor = normalBorderColor
        layer.borderWidth = normalBorderWidth
        layer.cornerRadius = 10 // Adjust for desired corner radius
    }
    
    override func becomeFirstResponder() -> Bool {
        let becomeActive = super.becomeFirstResponder()
        if becomeActive {
            // Highlight the border when textField is focused
            layer.borderColor = highlightedBorderColor
            layer.borderWidth = highlightedBorderWidth
        }
        return becomeActive
    }
    
    override func resignFirstResponder() -> Bool {
        let resignActive = super.resignFirstResponder()
        if resignActive {
            // Revert to the normal border when textField is not focused
            layer.borderColor = normalBorderColor
            layer.borderWidth = normalBorderWidth
        }
        return resignActive
    }
    
    // MARK: - Padding Overrides
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    func applyTheme(_ theme: PDSTheme) {
        normalBorderColor = theme.color.darkenPrimaryColor.cgColor
        highlightedBorderColor = theme.color.primaryColor.cgColor
        font = theme.typography.body
    }
}

struct PDSTextField_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreviewWrapper {
            let textField = PDSTextField()
            textField.placeholder = "Password"
            textField.autocapitalizationType = .none
            return textField
        }
        .fixedSize()
        .previewLayout(.sizeThatFits)
    }
}
