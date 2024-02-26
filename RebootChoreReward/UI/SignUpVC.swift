//
//  SignUpVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import SwiftUI

class SignUpVC: UIViewController {
    private let authService = AuthService.shared
    let emailTextField: PDSTextField = {
        let textField = PDSTextField()
        textField.placeholder = "Email"
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let passwordTextField: PDSTextField = {
        let textField = PDSTextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpActions()
    }
    
    func setUpViews() {
        view.backgroundColor = .systemBackground

        // Add subviews
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signUpButton)
        
        // Auto Layout constraints
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            signUpButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func setUpActions() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print ("Email or password is missing.")
            return
        }
        
        Task {
            await AuthService.shared.signUp(withEmail: email, password: password)
        }
    }
}

struct SignUpVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            SignUpVC()
        }
    }
}


