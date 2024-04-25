
//  LandingVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import SwiftUI
import UIKit

class LandingVC: UIViewController {
    private let dependencyView: Dependency.View
    
    private let welcomeLabel: PDSLabel = {
        let label = PDSLabel(withText: "Welcome to \nChore Reward", fontScale: .headline1)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logInButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Log in", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let signUpButton: PDSSecondaryButton = {
        let button = PDSSecondaryButton()
        button.setTitle("Sign up", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorLabel: PDSLabel = {
        let label = PDSLabel(withText: "or", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let enterInviteCode: PDSTertiaryButton = {
        let button = PDSTertiaryButton()
        button.setTitle("Enter invite code", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(
        dependencyView: Dependency.View
    ) {
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
        let leftSeparator = UIView.createSeparatorView()
        let rightSeparator = UIView.createSeparatorView()
        
        view.addSubview(welcomeLabel)
        view.addSubview(logInButton)
        view.addSubview(signUpButton)
        view.addSubview(separatorLabel)
        view.addSubview(enterInviteCode)
        view.addSubview(leftSeparator)
        view.addSubview(rightSeparator)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            enterInviteCode.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            enterInviteCode.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            separatorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separatorLabel.bottomAnchor.constraint(equalTo: enterInviteCode.topAnchor, constant: -20),
            
            leftSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            leftSeparator.trailingAnchor.constraint(equalTo: separatorLabel.leadingAnchor, constant: -20),
            leftSeparator.centerYAnchor.constraint(equalTo: separatorLabel.centerYAnchor),
            
            rightSeparator.leadingAnchor.constraint(equalTo: separatorLabel.trailingAnchor, constant: 20),
            rightSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rightSeparator.centerYAnchor.constraint(equalTo: separatorLabel.centerYAnchor),
            
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logInButton.bottomAnchor.constraint(equalTo: separatorLabel.topAnchor, constant: -20),
            logInButton.trailingAnchor.constraint(equalTo: signUpButton.leadingAnchor, constant: -20),
            
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.bottomAnchor.constraint(equalTo: separatorLabel.topAnchor, constant: -20),
            signUpButton.widthAnchor.constraint(equalTo: logInButton.widthAnchor, multiplier: 1)
        ])
    }

    private func setUpActions() {
        signUpButton.addTarget(self, action: #selector(navigateToSignUp), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(navigateToLogIn), for: .touchUpInside)
    }
    
    @objc func navigateToSignUp() {
        let signUpVC = dependencyView.signUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func navigateToLogIn() {
        let logInVC = dependencyView.logInVC()
        navigationController?.pushViewController(logInVC, animated: true)
    }
}

struct LandingVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.landingVC()
        }
    }
}

extension Dependency.View {
    func landingVC() -> LandingVC {
        return LandingVC(
            dependencyView: self
        )
    }
}

