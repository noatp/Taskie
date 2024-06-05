//
//  PDSTextView.swift
//  Taskie
//
//  Created by Toan Pham on 6/4/24.
//

import UIKit

class PDSTextView: UITextView, Themable {
    var normalBorderColor = UIColor.gray.cgColor
    var highlightedBorderColor = UIColor.systemBlue.cgColor
    
    func applyTheme(_ theme: PDSTheme) {
        placeholderLabel.font = theme.typography.body
        font = theme.typography.body
        keyboardAppearance = .dark
        autocorrectionType = .no
        normalBorderColor = theme.color.darkenPrimaryColor.cgColor
        highlightedBorderColor = theme.color.primaryColor.cgColor
        layer.borderColor = normalBorderColor
        layer.borderWidth = 1.0
        layer.cornerRadius = theme.styling.cornerRadius
    }
    
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.lightGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)
        setUpView()
        addPadding()
    }
    
    private func setUpView() {
        ThemeManager.shared.register(self)
        
        addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 17),
            placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            placeholderLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
        ])
    }
    
    private func addPadding() {
        // Set the text container inset
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    override func becomeFirstResponder() -> Bool {
        let becomeActive = super.becomeFirstResponder()
        if becomeActive {
            layer.borderColor = highlightedBorderColor
        }
        return becomeActive
    }
    
    override func resignFirstResponder() -> Bool {
        let resignActive = super.resignFirstResponder()
        if resignActive {
            layer.borderColor = normalBorderColor
        }
        return resignActive
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
}
