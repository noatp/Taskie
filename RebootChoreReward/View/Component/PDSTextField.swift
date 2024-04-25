//
//  PDSTextField.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class PDSTextField: UITextField, Themable {
    private var normalBorderColor = UIColor.gray.cgColor
    private var highlightedBorderColor = UIColor.systemBlue.cgColor
    
    private let normalBorderWidth: CGFloat = 1.0
    private let highlightedBorderWidth: CGFloat = 3.0
    
    private let placeholderText: String
    private let hasBorder: Bool
    private let maxChar: Int?
    private var textPadding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    init(withPlaceholder placeholderText: String, hasBorder: Bool = false, isCentered: Bool = false, maxChar: Int? = nil) {
        self.placeholderText = placeholderText
        self.hasBorder = hasBorder
        self.maxChar = maxChar
        super.init(frame: .zero)
        if isCentered {
            self.delegate = self
        }
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextField() {
        ThemeManager.shared.register(self)
    }
    
    override func becomeFirstResponder() -> Bool {
        let becomeActive = super.becomeFirstResponder()
        if becomeActive && hasBorder{
            layer.borderColor = highlightedBorderColor
            layer.borderWidth = highlightedBorderWidth
        }
        return becomeActive
    }
    
    override func resignFirstResponder() -> Bool {
        let resignActive = super.resignFirstResponder()
        if resignActive && hasBorder{
            layer.borderColor = normalBorderColor
            layer.borderWidth = normalBorderWidth
        }
        return resignActive
    }
    
    // MARK: - Padding Overrides
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return hasBorder ? bounds.inset(by: textPadding) : bounds
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return hasBorder ? bounds.inset(by: textPadding) : bounds
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return hasBorder ? bounds.inset(by: textPadding) : bounds
    }
    
    func applyTheme(_ theme: PDSTheme) {
        font = theme.typography.body
        placeholder = placeholderText
        textAlignment = .center
        keyboardAppearance = .dark
        autocorrectionType = .no
        if hasBorder {
            normalBorderColor = theme.color.darkenPrimaryColor.cgColor
            highlightedBorderColor = theme.color.primaryColor.cgColor
            layer.borderColor = normalBorderColor
            layer.borderWidth = normalBorderWidth
            layer.cornerRadius = theme.styling.cornerRadius
        }
    }
}

extension PDSTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        textField.textAlignment = newText.isEmpty ? .left : .center
        if let maxChar = maxChar {
            return newText.count <= maxChar
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            textField.textAlignment = .left
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
