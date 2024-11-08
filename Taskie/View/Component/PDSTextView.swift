//
//  PDSTextView.swift
//  Taskie
//
//  Created by Toan Pham on 6/4/24.
//

import UIKit
import SwiftUI

class PDSTextView: UITextView, Themable {
    var normalBorderColor = UIColor.gray.cgColor
    var highlightedBorderColor = UIColor.systemBlue.cgColor
    
    var onContentSizeChange: (() -> Void)?
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidEndEditingNotification, object: nil)
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
        textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
        onContentSizeChange?()
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let range = NSMakeRange(self.text.count - 1, 1)
            self.scrollRangeToVisible(range)
            // Correct the offset to the bottom if needed
            let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
            self.setContentOffset(bottomOffset, animated: false)
        }
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


struct PDSTextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    @Binding var dynamicHeight: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = PDSTextView()
        textView.placeholder = placeholder
        textView.delegate = context.coordinator
        textView.onContentSizeChange = {
            DispatchQueue.main.async {
                PDSTextViewWrapper.recalculateHeight(view: textView, result: $dynamicHeight)
            }
        }
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != self.text {
            uiView.text = self.text
            PDSTextViewWrapper.recalculateHeight(view: uiView, result: $dynamicHeight)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: PDSTextViewWrapper
        
        init(_ parent: PDSTextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
    
    static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        guard let textView = view as? PDSTextView else { return }
        
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: .greatestFiniteMagnitude))
        let roundedHeight = ceil(size.height)
        if abs(result.wrappedValue - roundedHeight) > 1.0 {
            DispatchQueue.main.async {
                if roundedHeight < 90 {
                    result.wrappedValue = roundedHeight
                }
            }
        }
    }
}

struct PDSTextViewWrapper_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack {
            PDSTextViewWrapper(text: .constant(""), placeholder: "Message", dynamicHeight: .constant(44))
                .frame(height: 44)
                .padding()
        }
    }
}
