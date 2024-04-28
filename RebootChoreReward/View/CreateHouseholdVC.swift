
//  CreateHouseholdVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/27/24.
//

import SwiftUI
import UIKit

class CreateHouseholdVC: PDSTitleWrapperVC {
    private var viewModel: CreateHouseholdViewModel
    private let dependencyView: Dependency.View
    
    private let promptCreateHouseholdLabel: PDSLabel = {
        let label = PDSLabel(withText: "If this is the first time your family is using Taskie, please create a Household.", fontScale: .caption)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let promptAddToHouseholdLabel: PDSLabel = {
        let label = PDSLabel(withText: "If somebody from your family is already using Taskie, please ask them to provide you with an invite code.", fontScale: .caption)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorLabel: PDSLabel = {
        let label = PDSLabel(withText: "or", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createHouseholdButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Create Household", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let enterInviteCodeButton: PDSSecondaryButton = {
        let button = PDSSecondaryButton()
        button.setTitle("Enter invite code", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: CreateHouseholdViewModel = .init(),
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
        setTitle("Let's get started")
        
        let leftSeparator = UIView.createSeparatorView()
        let rightSeparator = UIView.createSeparatorView()
        
        view.addSubview(promptCreateHouseholdLabel)
        view.addSubview(promptAddToHouseholdLabel)
        view.addSubview(separatorLabel)
        view.addSubview(createHouseholdButton)
        view.addSubview(enterInviteCodeButton)
        view.addSubview(leftSeparator)
        view.addSubview(rightSeparator)
        
        NSLayoutConstraint.activate([
            separatorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            separatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            leftSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            leftSeparator.trailingAnchor.constraint(equalTo: separatorLabel.leadingAnchor, constant: -20),
            leftSeparator.centerYAnchor.constraint(equalTo: separatorLabel.centerYAnchor),
            
            rightSeparator.leadingAnchor.constraint(equalTo: separatorLabel.trailingAnchor, constant: 20),
            rightSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rightSeparator.centerYAnchor.constraint(equalTo: separatorLabel.centerYAnchor),
            
            enterInviteCodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterInviteCodeButton.bottomAnchor.constraint(equalTo: separatorLabel.topAnchor, constant: -40),
            
            promptAddToHouseholdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptAddToHouseholdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptAddToHouseholdLabel.bottomAnchor.constraint(equalTo: enterInviteCodeButton.topAnchor, constant: -40),
            
            promptCreateHouseholdLabel.topAnchor.constraint(equalTo: separatorLabel.bottomAnchor, constant: 40),
            promptCreateHouseholdLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptCreateHouseholdLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            createHouseholdButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            createHouseholdButton.topAnchor.constraint(equalTo: promptCreateHouseholdLabel.bottomAnchor, constant: 40)
        ])
    }

    private func setUpActions() {
        
    }
    
    @objc func handleBack() {
    }
}

struct CreateHouseholdVC_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CreateHouseholdViewModel()
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
