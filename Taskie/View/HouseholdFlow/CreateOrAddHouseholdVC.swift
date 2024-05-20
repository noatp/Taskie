
//  CreateOrAddHouseholdVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import SwiftUI
import UIKit
import Combine

class CreateOrAddHouseholdVC: PDSTitleWrapperVC {
    private var viewModel: CreateOrAddHouseholdViewModel
    private let dependencyView: Dependency.View
    private var cancellables: Set<AnyCancellable> = []

    private let promptCreateHouseholdLabel: PDSLabel = {
        let label = PDSLabel(withText: "If this is your first time you and your family is using Taskie, please create a Household.", fontScale: .caption)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createNewHouseholdButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Create new Household", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let promptSearchHouseholdLabel: PDSLabel = {
        let label = PDSLabel(withText: "Otherwise, you can request to join an existing Household of your family.", fontScale: .caption)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchExistingHouseholdButton: PDSSecondaryButton = {
        let button = PDSSecondaryButton()
        button.setTitle("Search for Household", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
        
    private let invitedLabel: PDSLabel = {
        let label = PDSLabel(withText: "You are invited to join an existing household.", fontScale: .headline2)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let joinButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Join", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var noInviteStackView = UIStackView()
    
    init(
        viewModel: CreateOrAddHouseholdViewModel,
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
    
    private func bindViewModel() {
        viewModel.$hasInvite
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasInvite in
                guard let self = self else {
                    return
                }
                
                if hasInvite {
                    invitedLabel.isHidden = false
                    joinButton.isHidden = false
                    noInviteStackView.isHidden = true
                }
                else {
                    invitedLabel.isHidden = true
                    joinButton.isHidden = true
                    noInviteStackView.isHidden = false
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hideLoadingIndicator()
    }
    
    private func setUpViews() {
        setTitle("Let's get started!")
        
        noInviteStackView = UIStackView.vStack(
            arrangedSubviews: [
                promptCreateHouseholdLabel,
                UIView.createSpacerView(height: 20),
                createNewHouseholdButton,
                UIView.createSpacerView(height: 40),
                UIView.createSeparatorView(),
                UIView.createSpacerView(height: 20),
                promptSearchHouseholdLabel,
                UIView.createSpacerView(height: 20),
                searchExistingHouseholdButton
            ],
            alignment: .center,
            shouldExpandSubviewWidth: true
        )
        noInviteStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(noInviteStackView)
        view.addSubview(invitedLabel)
        view.addSubview(joinButton)
        
        NSLayoutConstraint.activate([
            noInviteStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noInviteStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noInviteStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            invitedLabel.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            invitedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            invitedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            joinButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            joinButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            joinButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 10)
        ])
    }
    
    private func setUpActions() {
        createNewHouseholdButton.addTarget(self, action: #selector(handleCreateNewHousehold), for: .touchUpInside)
        joinButton.addTarget(self, action: #selector(handleJoinHousehold), for: .touchUpInside)
    }
    
    @objc private func handleCreateNewHousehold() {
        let createHouseholdVC = self.dependencyView.createHouseholdVC()
        navigationController?.pushViewController(createHouseholdVC, animated: true)
    }
    
    @objc private func handleJoinHousehold() {
        viewModel.joinHouseholdFromInvite()
    }
}

struct CreateOrAddHouseholdVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.createOrAddHouseholdVC()
        }
    }
}

extension Dependency.View {
    func createOrAddHouseholdVC() -> CreateOrAddHouseholdVC {
        return CreateOrAddHouseholdVC(
            viewModel: viewModel.createOrAddHouseholdViewModel(),
            dependencyView: self
        )
    }
}
