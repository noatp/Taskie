//
//  ErrorWindow.swift
//  Taskie
//
//  Created by Toan Pham on 5/13/24.
//

import UIKit

class ErrorWindow: UIWindow {
    static let shared = ErrorWindow(frame: UIScreen.main.bounds)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        windowLevel = UIWindow.Level.alert + 1
        rootViewController = PDSAlertVC()
    }
    
    func showAlert(alertTitle: String = "", alertMessage: String, buttonTitle: String = "Dismiss", buttonAction: (() -> ())? = nil) {
        guard let alertVC = rootViewController as? PDSAlertVC else {
            return
        }
        
        if let buttonAction = buttonAction {
            alertVC.configureAlert(alertTitle: alertTitle, alertMessage: alertMessage, buttonTitle: buttonTitle) {
                DispatchQueue.main.async { [weak self] in
                    self?.isHidden = true
                    buttonAction()
                }
            }
        }
        else {
            alertVC.configureAlert(alertTitle: alertTitle, alertMessage: alertMessage, buttonTitle: buttonTitle) {
                DispatchQueue.main.async { [weak self] in
                    self?.isHidden = true
                }
            }
        }
        
        isHidden = false
        
    }
}
