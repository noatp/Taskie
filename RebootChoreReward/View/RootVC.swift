//
//  RootVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import Combine

class RootVC: UIViewController {
    private var viewModel: RootViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var dependencyView: Dependency.View
    private var choreListVC: UINavigationController
    
    init(viewModel: RootViewModel, dependencyView: Dependency.View) {
        self.viewModel = viewModel
        self.dependencyView = dependencyView
        self.choreListVC = UINavigationController(rootViewController: dependencyView.choreListVC())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        addChild(choreListVC)
        choreListVC.didMove(toParent: self)
        setUpViews()
    }
    
    private func setUpViews() {
        view.backgroundColor = .systemBackground

        guard let childView = choreListVC.view else {
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
    
    private func bindViewModel() {
        viewModel.$authState
            .receive(on: RunLoop.main)
            .sink { [weak self] isUserLoggedIn in
                isUserLoggedIn ? self?.dismissLogInVC() : self?.presentLogInVC()
            }
            .store(in: &cancellables)

    }
    
    private func presentLogInVC() {
        if presentedViewController is LogInVC {
            return
        }
        
        let logInVC = dependencyView.loginInVC()
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

extension Dependency.View {
    func rootVC() -> RootVC {
        return RootVC(
            viewModel: viewModel.rootViewModel(),
            dependencyView: self
        )
    }
}

