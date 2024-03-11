//
//  SignUpVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import SwiftUI

class SignUpVC: UIViewController {
    private var viewModel: SignUpViewModel
    var signUpButtonBottomConstraint: NSLayoutConstraint = .init()
    
    let emailTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Email")
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let passwordTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Password")
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let signUpButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Sign up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: SignUpViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNotificationObserver()
        setUpViews()
        setUpActions()
    }
    
    private func setUpViews() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        signUpButtonBottomConstraint = signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        
        // Auto Layout constraints
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signUpButtonBottomConstraint,
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setUpActions() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }
    
    private func setUpNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func showAlert(withMessage alertMessage: String) {
        let alertVC = AlertVC(alertMessage: alertMessage)
        alertVC.modalPresentationStyle = .overCurrentContext
        alertVC.modalTransitionStyle = .crossDissolve
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func handleSignUp() {
        viewModel.email = emailTextField.text
        viewModel.password = passwordTextField.text
        
        viewModel.signUp { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.showAlert(withMessage: errorMessage)
                } else {
                    // Handle successful signup
                }
            }
        }
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardFrame.height
            signUpButtonBottomConstraint.constant = -keyboardHeight - 20
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        signUpButtonBottomConstraint.constant = -100
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        removeNotificationObserver()
    }
}

struct SignUpVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            SignUpVC()
        }
    }
}


