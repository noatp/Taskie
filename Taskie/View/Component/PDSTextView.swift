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
                self.dynamicHeight = textView.contentSize.height
            }
        }
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        PDSTextViewWrapper.recalculateHeight(view: uiView, result: $dynamicHeight)
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
        let size = view.sizeThatFits(CGSize(width: view.frame.size.width, height: .greatestFiniteMagnitude))
        if result.wrappedValue != size.height {
            DispatchQueue.main.async {
                result.wrappedValue = size.height
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
