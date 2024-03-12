//
//  PDSViewController.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/11/24.
//

import UIKit

// inherit this UIViewController to has the ability to resize view when keyboard shows
class PDSViewController: UIViewController {
    var keyboardAdjustmentConstraint: NSLayoutConstraint = .init()
    var bottomConstraintValue: CGFloat = 0
    var bottomConstraintOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardObservers()
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        bottomConstraintValue = -keyboardSize.height - bottomConstraintOffset
        keyboardAdjustmentConstraint.constant = bottomConstraintValue
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraintValue = -100
        keyboardAdjustmentConstraint.constant = bottomConstraintValue
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    deinit {
        removeKeyboardObservers()
    }
}
