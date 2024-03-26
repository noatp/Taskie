//
//  SignUpVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import SwiftUI

class SignUpVC: PDSViewController {
    private var viewModel: SignUpViewModel
    
    let nameTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Name", hasBorder: true)
        textField.autocapitalizationType = .none
        textField.keyboardType = .namePhonePad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
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
    let signUpButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Sign up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: SignUpViewModel) {
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
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            nameTextField,
            UIView.createSpacerView(height: 40),
            emailTextField,
            UIView.createSpacerView(height: 40),
            passwordTextField,
            UIView.createSpacerView(),
            signUpButton
        ], alignment: .center, shouldExpandSubviewWidth: true)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        
        keyboardAdjustmentConstraint = vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            keyboardAdjustmentConstraint
        ])
    }
    
    private func setUpActions() {
        signUpButton.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
    }
    
    @objc func handleSignUp() {
        viewModel.email = emailTextField.text
        viewModel.password = passwordTextField.text
        viewModel.name = nameTextField.text
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
}

struct SignUpVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.signUpVC()
        }
    }
}

extension Dependency.View {
    func signUpVC() -> SignUpVC {
        return SignUpVC(
            viewModel: viewModel.signUpViewModel()
        )
    }
}


