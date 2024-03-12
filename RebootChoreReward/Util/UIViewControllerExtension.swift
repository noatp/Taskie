//
//  UIViewControllerExtension.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/11/24.
//

import UIKit

extension UIViewController {
    func showAlert(withMessage alertMessage: String) {
        let alertVC = AlertVC(alertMessage: alertMessage)
        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
}
