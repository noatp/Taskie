
//  AddChoreVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import SwiftUI
import UIKit

class AddChoreVC: PDSViewController {
    private var viewModel: AddChoreViewModel
    
    private let titleLabel: PDSLabel = {
        let label = PDSLabel(withText: "Create chore", fontScale: .headline1, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let choreNameTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Chore name")
        textField.font = PDSTheme.defaultTheme.typography.headline2
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let choreDescriptionTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Chore description")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let rewardLabel: PDSLabel = {
        let label = PDSLabel(withText: "Reward", fontScale: .caption, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let choreRewardAmountTextField: PDSCurrencyTextField = {
        let textField = PDSCurrencyTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let createChoreButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "Create"
        config.baseBackgroundColor = PDSTheme.defaultTheme.color.primaryColor
        config.baseForegroundColor = PDSTheme.defaultTheme.color.onPrimary
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = PDSTheme.defaultTheme.typography.button
            return outgoing
        }
        config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
            return button.isHighlighted ? PDSTheme.defaultTheme.color.darkenPrimaryColor : PDSTheme.defaultTheme.color.primaryColor
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: AddChoreViewModel = .init()) {
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
        view.backgroundColor = PDSTheme.defaultTheme.color.surfaceColor
        
        let vStack = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView.createSpacerView(height: 40),
            choreNameTextField,
            UIView.createSpacerView(height: 20),
            choreDescriptionTextField,
            UIView.createSpacerView(height: 40),
            rewardLabel,
            UIView.createSpacerView(height: 10),
            choreRewardAmountTextField
        ])
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.alignment = .center
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        view.addSubview(createChoreButton)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            createChoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createChoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createChoreButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setUpActions() {
        createChoreButton.addTarget(self, action: #selector(handleCreateChore), for: .touchUpInside)
    }
    
    @objc func handleCreateChore() {
        viewModel.choreName = choreNameTextField.text
        viewModel.choreDescription = choreDescriptionTextField.text
        viewModel.choreRewardAmount = choreRewardAmountTextField.text
        
        viewModel.createChore { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let errorMessage = errorMessage {
                    self?.showAlert(withMessage: errorMessage)
                }
                else {
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
        createChoreButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: -self.bottomConstraintValue + 20, trailing: 20)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
        createChoreButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        UIView.animate(withDuration: 0.3) { self.view.layoutIfNeeded() }
    }
}

struct AddChoreVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            let baseVC = UIViewController()
            let addChoreVC = AddChoreVC()
            DispatchQueue.main.async {
                baseVC.present(addChoreVC, animated: true, completion: nil)
            }
            
            return baseVC
        }
    }
}
 
