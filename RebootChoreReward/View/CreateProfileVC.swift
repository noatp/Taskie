
//  CreateProfileVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/27/24.
//

import SwiftUI
import UIKit

class CreateProfileVC: PDSResizeWithKeyboardVC {
    private var viewModel: CreateProfileViewModel
    private let dependencyView: Dependency.View
    
    private let nameTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Your name", hasBorder: true)
        textField.autocapitalizationType = .none
        textField.keyboardType = .namePhonePad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let submitButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Submit", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let backBarButton: PDSTertiaryButton = {
        let button = PDSTertiaryButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: CreateProfileViewModel,
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
        setTitle("About you")
        
        view.addSubview(nameTextField)
        view.addSubview(submitButton)
        
        keyboardAdjustmentConstraint = submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            keyboardAdjustmentConstraint
        ])
    }

    private func setUpActions() {
        submitButton.addTarget(self, action: #selector(handleCreateUser), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleCreateUser() {
        viewModel.name = nameTextField.text
        viewModel.createHouseholdAndUser { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.showAlert(withMessage: errorMessage)
                }
            }
        }
    }
}

struct CreateProfileVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.createProfileVC()
        }
    }
}
 
extension Dependency.View {
    func createProfileVC() -> CreateProfileVC {
        return CreateProfileVC(
            viewModel: viewModel.createProfileViewModel(),
            dependencyView: self
        )
    }
}
