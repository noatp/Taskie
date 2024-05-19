//
//  EnterNameVC.swift
//  Taskie
//
//  Created by Toan Pham on 5/7/24.
//

import UIKit
import SwiftUI
import Combine

class EnterNameVC: PDSResizeWithKeyboardVC {
    private let viewModel: EnterNameViewModel
    private var cancellables: Set<AnyCancellable> = []

    private lazy var emailPrompt: PDSLabel = {
        let label = PDSLabel(withText: "What's your name?", fontScale: .headline2)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailPromptInfo: PDSLabel = {
        let label = PDSLabel(withText: "Enter your first and last name.", fontScale: .body)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Name", hasBorder: true)
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
    
    init(viewModel: EnterNameViewModel) {
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
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        _ = nameTextField.becomeFirstResponder()
    }
    
    private func bindViewModel() {
        viewModel.$nameCheckResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] nameCheckResult in
                guard let self = self,
                      let nameCheckResult = nameCheckResult
                else {
                    return
                }
                
                switch nameCheckResult {
                    case .success():
                        break
                    case .failure(let error):
                        showAlert(alertMessage: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        setTitle("Sign up")
        
        let nameTextFieldTopSpace = UIView.createSpacerView()
        let nameTextFieldBottomSpace = UIView.createSpacerView()
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            emailPrompt,
            emailPromptInfo,
            nameTextFieldTopSpace,
            nameTextField,
            nameTextFieldBottomSpace,
            continueButton,
        ], alignment: .center, shouldExpandSubviewWidth: true)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            nameTextFieldTopSpace.heightAnchor.constraint(equalTo: nameTextFieldBottomSpace.heightAnchor),
            constraintViewToKeyboard(vStack)
        ])
    }
    
    private func setUpActions() {
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
    }
    
    @objc func handleContinue() {
        viewModel.checkNameForSignUp(nameTextField.text)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

struct EnterNameVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.enterNameVC()
        }
    }
}

extension Dependency.View {
    func enterNameVC() -> EnterNameVC {
        return EnterNameVC(
            viewModel: viewModel.enterNameViewModel()
        )
    }
}


