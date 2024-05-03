
//  CreateHouseholdVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import SwiftUI
import UIKit

class CreateHouseholdVC: PDSResizeWithKeyboardVC {
    private var viewModel: CreateHouseholdViewModel
    private let dependencyView: Dependency.View

    private let promptLabel: PDSLabel = {
        let label = PDSLabel(withText: "Enter a nickname for your Household. Your household can be found using this nickname.", fontScale: .caption)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tagTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Nickname", hasBorder: true, isCentered: true)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let createHouseholdButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Create", for: .normal)
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
        viewModel: CreateHouseholdViewModel,
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
        setTitle("Create household")
        
        view.addSubview(promptLabel)
        view.addSubview(tagTextField)
        view.addSubview(createHouseholdButton)
        
        keyboardAdjustmentConstraint = createHouseholdButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tagTextField.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 20),
            tagTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tagTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            keyboardAdjustmentConstraint,
            createHouseholdButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createHouseholdButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setUpActions() {
        createHouseholdButton.addTarget(self, action: #selector(handleCreateHousehold), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleCreateHousehold() {
        viewModel.tag = tagTextField.text
        viewModel.createHousehold()
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

struct CreateHouseholdVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.createHouseholdVC()
        }
    }
}
 
extension Dependency.View {
    func createHouseholdVC() -> CreateHouseholdVC {
        return CreateHouseholdVC(
            viewModel: viewModel.createHouseholdViewModel(),
            dependencyView: self
        )
    }
}
