//
//  UIViewControllerExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/11/24.
//

import UIKit

extension UIViewController {
    func showAlert(
        withTitle alertTitle: String = "Something went wrong",
        alertMessage: String,
        buttonTitle: String = "Dismiss",
        buttonAction: (() -> Void)? = nil
    ) {
        let alertVC = PDSAlertVC(alertTitle: alertTitle, alertMessage: alertMessage, buttonTitle: buttonTitle, buttonAction: buttonAction)
        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
    
    func showLoadingIndicator() {
        let loadingIndicatorVC = PDSLoadingIndicator()
        loadingIndicatorVC.modalPresentationStyle = .overCurrentContext
        loadingIndicatorVC.modalTransitionStyle = .crossDissolve
        
        present(loadingIndicatorVC, animated: true)
    }
    
    func hideLoadingIndicator(completion: (() -> Void)? = nil) {
        if let _ = presentedViewController as? PDSLoadingIndicator {
            dismiss(animated: false, completion: completion)
        }
        else {
            completion?()
        }
    }
}
