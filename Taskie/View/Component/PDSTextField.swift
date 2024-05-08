//
//  PDSTextField.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class PDSTextField: UITextField, Themable {
    private let hasBorder: Bool
    private var textPadding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    init(withPlaceholder placeholderText: String, hasBorder: Bool = false, textAlignment: NSTextAlignment = .center, maxChar: Int? = nil) {
        self.hasBorder = hasBorder
        super.init(frame: .zero)
        self.placeholder = placeholderText
        self.textAlignment = textAlignment
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextField() {
        ThemeManager.shared.register(self)
        keyboardAppearance = .dark
        autocorrectionType = .no
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
        font = theme.typography.body
 
        if hasBorder {
            layer.borderColor = theme.color.secondaryColor.cgColor
            layer.borderWidth = 1.0
            layer.cornerRadius = theme.styling.cornerRadius
        }
    }
}

struct PDSTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UIViewPreviewWrapper {
                let textField = PDSTextField(withPlaceholder: "Password", hasBorder: true)
                return textField
            }
            .fixedSize()
            
            UIViewPreviewWrapper {
                let textField = PDSTextField(withPlaceholder: "Password")
                return textField
            }
            .fixedSize()
        }
        
        .previewLayout(.sizeThatFits)
    }
}
