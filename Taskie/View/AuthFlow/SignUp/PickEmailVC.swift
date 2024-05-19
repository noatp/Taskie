//
//  PickEmailVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import SwiftUI
import Combine

class PickEmailVC: PDSResizeWithKeyboardVC {
    private let viewModel: SignUpViewModel
    private let dependencyView: Dependency.View
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var emailPrompt: PDSLabel = {
        let label = PDSLabel(withText: "What's your email address?", fontScale: .headline2)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailPromptInfo: PDSLabel = {
        let label = PDSLabel(withText: "You'll use this email to log in next time.", fontScale: .body)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Email", hasBorder: true)
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let continueButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Continue", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let backBarButton: PDSIconBarButton = {
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
        _ = emailTextField.becomeFirstResponder()
    }
    
    private func bindViewModel() {
        viewModel.$signUpResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] signUpResult in
                guard let self = self,
                      let signUpResult = signUpResult
                else {
                    return
                }
                
                switch signUpResult {
                    case .success():
                        self.navigateToPickPassword()
                    case .failure(let error):
                        showAlert(alertMessage: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        setTitle("Sign up")
        
        let emailTextFieldTopSpace = UIView.createSpacerView()
        let emailTextFieldBottomSpace = UIView.createSpacerView()
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            emailPrompt,
            emailPromptInfo,
            emailTextFieldTopSpace,
            emailTextField,
            emailTextFieldBottomSpace,
            continueButton,
        ], alignment: .center, shouldExpandSubviewWidth: true)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),            
            emailTextFieldTopSpace.heightAnchor.constraint(equalTo: emailTextFieldBottomSpace.heightAnchor),
            constraintViewToKeyboard(vStack)
        ])
    }
    
    private func setUpActions() {
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    private func navigateToPickPassword() {
        let pickPasswordVC = dependencyView.pickPasswordVC()
        navigationController?.pushViewController(pickPasswordVC, animated: true)
    }
    
    @objc func handleContinue() {
        viewModel.checkEmailForSignUp(emailTextField.text)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

struct PickEmailVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.pickEmailVC()
        }
    }
}

extension Dependency.View {
    func pickEmailVC() -> PickEmailVC {
        return PickEmailVC(
            viewModel: viewModel.signUpViewModel(), dependencyView: self
        )
    }
}


