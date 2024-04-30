
//  LandingVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/24/24.
//

import SwiftUI
import UIKit
import Combine

class LandingVC: UIViewController, Themable {
    private let viewModel: LandingViewModel
    private let dependencyView: Dependency.View
    private var cancellables: Set<AnyCancellable> = []
        
    private let welcomeLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline1)
        
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
    
    let backBarButton: PDSTertiaryButton = {
        let button = PDSTertiaryButton()
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: LandingViewModel,
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
        ThemeManager.shared.register(self)
        
        view.addSubview(welcomeLabel)
        view.addSubview(logInButton)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            logInButton.trailingAnchor.constraint(equalTo: signUpButton.leadingAnchor, constant: -20),
            
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            signUpButton.widthAnchor.constraint(equalTo: logInButton.widthAnchor, multiplier: 1)
        ])
    }
    
    private func setUpActions() {
        signUpButton.addTarget(self, action: #selector(navigateToSignUp), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(navigateToLogIn), for: .touchUpInside)
    }
    
    @objc func navigateToSignUp() {
        let preSignUpVC = self.dependencyView.preSignUpVC()
        navigationController?.pushViewController(preSignUpVC, animated: true)
    }
    
    @objc func navigateToLogIn() {
        let logInVC = dependencyView.logInVC()
        navigationController?.pushViewController(logInVC, animated: true)
    }
    
    func applyTheme(_ theme: PDSTheme) {
        let fullText = "Welcome to\nChore Reward"
        let attributedString = NSMutableAttributedString(string: fullText)
        let normalAttribute: [NSAttributedString.Key: Any] = [.foregroundColor: theme.color.onBackground]
        let choreAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: theme.color.primaryColor]
        let rewardAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: theme.color.secondaryColor]
        
        attributedString.addAttributes(normalAttribute, range: (fullText as NSString).range(of: fullText))
        attributedString.addAttributes(choreAttributes, range: (fullText as NSString).range(of: "Chore"))
        attributedString.addAttributes(rewardAttributes, range: (fullText as NSString).range(of: "Reward"))
        
        welcomeLabel.attributedText = attributedString
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
            viewModel: viewModel.landingViewModel(),
            dependencyView: self
        )
    }
}

