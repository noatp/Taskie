//
//  LogInVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import SwiftUI

class LogInVC: PDSResizeWithKeyboardVC {
    private var viewModel: LogInViewModel
    private let dependencyView: Dependency.View
    
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
    
    init(
        viewModel: LogInViewModel,
        dependencyView: Dependency.View
    ) {
        self.viewModel = viewModel
        self.dependencyView = dependencyView
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
        setTitle("Log in")
        
        view.backgroundColor = .systemBackground
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            emailTextField,
            .createSpacerView(height: 20),
            passwordTextField,
            .createSpacerView(),
            logInButton,
            .createSpacerView(height: 20),
            navToSignUpVCButton
        ], alignment: .center, shouldExpandSubviewWidth: true)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        keyboardAdjustmentConstraint = vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            keyboardAdjustmentConstraint,
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
        let signUpVC = dependencyView.signUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
}

struct LogInVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.loginInVC()
        }
    }
}

extension Dependency.View {
    func loginInVC() -> LogInVC {
        return LogInVC(
            viewModel: viewModel.logInViewModel(),
            dependencyView: self
        )
    }
}
