//
//  LogInVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import SwiftUI

class LogInVC: PDSViewController {
    private var viewModel: LogInViewModel
    
    let emailTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Email", hasBorder: true)
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let passwordTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Password", hasBorder: true)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let logInButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Log in", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let navToSignUpVCButton: PDSSecondaryButton = {
        let button = PDSSecondaryButton()
        button.setTitle("Sign up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: LogInViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpActions()
    }
    
    private func setUpViews() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(logInButton)
        view.addSubview(navToSignUpVCButton)
        
        keyboardAdjustmentConstraint = navToSignUpVCButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            navToSignUpVCButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 20),
            keyboardAdjustmentConstraint,
            navToSignUpVCButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            navToSignUpVCButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setUpActions() {
        logInButton.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        navToSignUpVCButton.addTarget(self, action: #selector(navigateToSignUp), for: .touchUpInside)
    }
    
    @objc func handleLogIn() {
        viewModel.email = emailTextField.text
        viewModel.password = passwordTextField.text
        
        viewModel.logIn { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.showAlert(withMessage: errorMessage)
                } else {
                    // Handle successful login
                }
            }
        }
    }
    
    @objc func navigateToSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
}

struct LogInVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            LogInVC()
        }
    }
}
