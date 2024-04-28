//
//  UIViewControllerExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/11/24.
//

import UIKit

extension UIViewController {
    func showAlert(withMessage alertMessage: String) {
        let alertVC = PDSAlertVC(alertMessage: alertMessage)
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
        dismiss(animated: false, completion: completion)
    }
}
