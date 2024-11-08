//
//  PDSCurrencyTextField.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/12/24.
//

import UIKit
import SwiftUI

class PDSCurrencyTextField: UITextField, Themable {
    var normalBorderColor = UIColor.gray.cgColor
    var highlightedBorderColor = UIColor.systemBlue.cgColor
    var textPadding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    let normalBorderWidth: CGFloat = 1.0
    let highlightedBorderWidth: CGFloat = 3.0
    let currencySymbol = "$"
    
    let hasBorder: Bool
    
    init(hasBorder: Bool = false) {
        self.hasBorder = hasBorder
        super.init(frame: .zero)
        self.delegate = self
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
        placeholder = currencySymbol + "0.00"
        keyboardAppearance = .dark
        keyboardType = .decimalPad
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

extension PDSCurrencyTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "\(currencySymbol)"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == currencySymbol {
            textField.text = ""
            textField.placeholder = "\(currencySymbol)0.00"
        } else {
            textField.text = textField.text?
                .stripDollarSign()
                .formatAmountInCents()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text as NSString? else { return true }
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.isEmpty == true {
            return false
        }
        else if updatedText == currencySymbol {
            return true
        }
        
        // Check if the new text is a valid number
        if let _ = Double(updatedText.stripDollarSign()) {
            // Check if the text contains a decimal point
            if let dotIndex = updatedText.firstIndex(of: ".") {
                // Get the substring after the decimal point
                let decimalPart = updatedText[dotIndex...].dropFirst()
                // Allow change only if the decimal part has 2 or fewer characters
                if decimalPart.count > 2 {
                    return false
                }
            }
            return true
        } else {
            // If the new text is not a valid number, disallow the change
            return false
        }
    }
}

struct PDSCurrencyTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UIViewPreviewWrapper {
                let textField = PDSCurrencyTextField(hasBorder: true)
                return textField
            }
            .fixedSize()
            
            UIViewPreviewWrapper {
                let textField = PDSCurrencyTextField()
                return textField
            }
            .fixedSize()
        }
        
        .previewLayout(.sizeThatFits)
    }
}
