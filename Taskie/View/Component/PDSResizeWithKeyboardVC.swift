//
//  PDSViewController.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/11/24.
//

import UIKit

// inherit this UIViewController to has the ability to resize view when keyboard shows
class PDSResizeWithKeyboardVC: PDSTitleWrapperVC {
    private var keyboardAdjustmentConstraint: NSLayoutConstraint = .init()
    private var bottomConstraintValue: CGFloat = 0
    private let bottomConstraintOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        addKeyboardObservers()
    }
    
    func constraintViewToKeyboard(_ bottomView: UIView) -> NSLayoutConstraint {
        keyboardAdjustmentConstraint = bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: bottomConstraintValue)
        return keyboardAdjustmentConstraint
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
        bottomConstraintValue = -keyboardSize.height
        keyboardAdjustmentConstraint.constant = bottomConstraintValue + 20
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraintValue = -bottomConstraintOffset
        keyboardAdjustmentConstraint.constant = bottomConstraintValue
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func getBottomConstraintValue() -> CGFloat {
        return bottomConstraintValue
    }
    
    deinit {
        removeKeyboardObservers()
    }
}
