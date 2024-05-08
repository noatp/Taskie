//
//  PickPasswordVC.swift
//  Taskie
//
//  Created by Toan Pham on 5/7/24.
//

import UIKit
import SwiftUI
import Combine

class PickPasswordVC: PDSResizeWithKeyboardVC {
    private let viewModel: SignUpViewModel
    private let dependencyView: Dependency.View
    private var cancellables: Set<AnyCancellable> = []

    private lazy var passwordPrompt: PDSLabel = {
        let label = PDSLabel(withText: "Choose a password", fontScale: .headline2)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordPromptInfo: PDSLabel = {
        let label = PDSLabel(withText: "Password must have at least 8 characters, one uppercase letter, and one lowercase letter.", fontScale: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Password", hasBorder: true)
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var continueButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Continue", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.left")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: SignUpViewModel,
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
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        passwordTextField.text = ""
        _ = passwordTextField.becomeFirstResponder()
    }
    
    private func bindViewModel() {
        viewModel.$infoState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] infoState in
                guard let self = self else {
                    return
                }
                
                switch infoState {
                    case .notChecked:
                        break
                    case .checked:
                        self.navigateToEnterName()
                    
                    case .invalid(errorMessage: let errorMessage):
                        self.showAlert(withMessage: errorMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        setTitle("Sign up")
        
        let passwordTextFieldTopSpace = UIView.createSpacerView()
        let passwordTextFieldBottomSpace = UIView.createSpacerView()
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            passwordPrompt,
            passwordPromptInfo,
            passwordTextFieldTopSpace,
            passwordTextField,
            passwordTextFieldBottomSpace,
            continueButton
        ], alignment: .center, shouldExpandSubviewWidth: true)
        vStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),            
            passwordTextFieldTopSpace.heightAnchor.constraint(equalTo: passwordTextFieldBottomSpace.heightAnchor),
            constraintViewToKeyboard(vStack)
        ])
    }
    
    private func setUpActions() {
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    private func navigateToEnterName() {
        let enterNameVC = dependencyView.enterNameVC()
        navigationController?.pushViewController(enterNameVC, animated: true)
    }
    
    @objc func handleContinue() {
        viewModel.checkPasswordForSignUp(passwordTextField.text)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

struct PickPasswordVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.pickPasswordVC()
        }
    }
}

extension Dependency.View {
    func pickPasswordVC() -> PickPasswordVC {
        return PickPasswordVC(
            viewModel: viewModel.signUpViewModel(), dependencyView: self
        )
    }
}
