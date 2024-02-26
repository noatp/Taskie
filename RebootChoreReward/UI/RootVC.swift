//
//  RootVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import Combine

class RootVC: UIViewController {
    private let authService = AuthService.shared
    private var authStateSubscriber: AnyCancellable?
    private let homeVC = HomeVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeAuthState()
        addChild(homeVC)
        homeVC.didMove(toParent: self)
        setUpViews()
    }
    
    private func setUpViews() {
        view.backgroundColor = .systemBackground

        guard let childView = homeVC.view else {
            return
        }
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            childView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }
    
    private func observeAuthState() {
        authStateSubscriber = AuthService.shared.isUserLoggedIn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isUserLoggedIn in
                if isUserLoggedIn {
                    self?.dismissLogInVC()
                }
                else {
                    self?.presentLogInVC()
                }
            }
    }
    
    private func presentLogInVC() {
        if presentedViewController is LogInVC {
            return
        }
        
        let logInVC = LogInVC()
        let logInFlowNavVC = UINavigationController(rootViewController: logInVC)
        logInFlowNavVC.modalPresentationStyle = .fullScreen
        present(logInFlowNavVC, animated: true)
    }
    
    private func dismissLogInVC() {
        if let navController = presentedViewController as? UINavigationController,
           navController.viewControllers.first is LogInVC {
            dismiss(animated: true)
        }
    }
    
}

