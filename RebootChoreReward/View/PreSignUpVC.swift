
//  PreSignUpVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/29/24.
//

import SwiftUI
import UIKit

class PreSignUpVC: PDSTitleWrapperVC {
    private var viewModel: PreSignUpViewModel
    private let dependencyView: Dependency.View
    private var vStack: UIStackView = .init()
    
    private let isParentQuestionLabel: PDSLabel = {
        let label = PDSLabel(withText: "Are you a parent?", fontScale: .headline2)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let isParentButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Yes", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let isNotParentButton: PDSSecondaryButton = {
        let button = PDSSecondaryButton()
        button.setTitle("No", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backBarButton: PDSTertiaryButton = {
        let button = PDSTertiaryButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let notYetLabel: PDSLabel = {
        let label = PDSLabel(withText: "Please ask your parents to download app and sign up on their phone.\nThen, they can send you an invitation link so you can sign up, too!", fontScale: .caption)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(
        viewModel: PreSignUpViewModel,
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
        setTitle("Quick question")
        
        vStack = UIStackView.vStack(
            arrangedSubviews: [
                isParentQuestionLabel,
                UIView.createSpacerView(height: 40),
                isParentButton,
                UIView.createSpacerView(height: 20),
                isNotParentButton
            ],
            alignment: .center,
            shouldExpandSubviewWidth: true
        )
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        view.addSubview(notYetLabel)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            notYetLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            notYetLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            notYetLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setUpActions() {
        isParentButton.addTarget(self, action: #selector(handleIsParent), for: .touchUpInside)
        isNotParentButton.addTarget(self, action: #selector(handleIsNotParent), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func handleIsParent() {
        let signUpVC = dependencyView.signUpVC()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func handleIsNotParent() {
        setTitle("Ask your parents")
        vStack.removeFromSuperview()
        notYetLabel.isHidden = false
    }
}

struct PreSignUpVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.preSignUpVC()
        }
    }
}

extension Dependency.View {
    func preSignUpVC() -> PreSignUpVC {
        return PreSignUpVC(
            viewModel: viewModel.preSignUpViewModel(),
            dependencyView: self
        )
    }
}
