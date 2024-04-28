
//  InviteCodeVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import SwiftUI
import UIKit
import Combine

class InviteCodeVC: PDSResizeWithKeyboardVC {
    private var viewModel: InviteCodeViewModel
    private let dependencyView: Dependency.View
    private var cancellables: Set<AnyCancellable> = []

    private let inviteCodeTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "000000", hasBorder: true, isCentered: true, maxChar: 6)
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    private let promptLabel: PDSLabel = {
        let label = PDSLabel(withText: "Please enter the 6 digits invite code", fontScale: .caption)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let submitButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Submit", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let backBarButton: PDSTertiaryButton = {
        let button = PDSTertiaryButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: InviteCodeViewModel,
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
        bindViewModel()
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        viewModel.$shouldNavigateToCreateProfileVC
            .receive(on: RunLoop.main)
            .sink { [weak self] shouldNavigateToCreateProfileVC in
                if shouldNavigateToCreateProfileVC {
                    guard let createProfileVC = self?.dependencyView.createProfileVC() else {
                        return
                    }
                    self?.navigationController?.pushViewController(createProfileVC, animated: true)
                }
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        setTitle("Invite Code")
        
        keyboardAdjustmentConstraint = submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
                
        view.addSubview(inviteCodeTextField)
        view.addSubview(promptLabel)
        view.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            inviteCodeTextField.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 20),
            inviteCodeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inviteCodeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            keyboardAdjustmentConstraint
        ])
    }

    private func setUpActions() {
        submitButton.addTarget(self, action: #selector(handleInviteCodeSubmit), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleInviteCodeSubmit() {
        viewModel.inviteCode = inviteCodeTextField.text
        viewModel.readInviteCode { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.showAlert(withMessage: errorMessage)
                }
            }
        }
    }
}

struct InviteCodeVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.inviteCodeVC()
        }
    }
}
 
extension Dependency.View {
    func inviteCodeVC() -> InviteCodeVC {
        return InviteCodeVC(
            viewModel: viewModel.inviteCodeViewModel(),
            dependencyView: self
        )
    }
}
