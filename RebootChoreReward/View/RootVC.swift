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
    private var current: UINavigationController
    
    init(viewModel: RootViewModel, dependencyView: Dependency.View) {
        self.viewModel = viewModel
        self.dependencyView = dependencyView
        self.current = UINavigationController(rootViewController: dependencyView.logInVC())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        addChild(current)
        current.didMove(toParent: self)
        setUpViews()
    }
    
    private func setUpViews() {
        view.backgroundColor = .systemBackground
        
        guard let childView = current.view else {
            return
        }
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        setupConstraints(for: childView)
    }
    
    private func bindViewModel() {
        viewModel.$isInHousehold
            .combineLatest(viewModel.$isUserDataAvailable)
            .receive(on: RunLoop.main)
            .sink { [weak self] isInHousehold, isUserDataAvailable in
                guard let self = self else {
                    return
                }
                
                if isInHousehold && isUserDataAvailable {
                    let choreListVC = self.dependencyView.choreListVC()
                    let navVC = UINavigationController(rootViewController: choreListVC)
                    self.switchToViewController(navVC)
                }
                else {
                    if self.viewModel.isLoggedIn {
                        let createHouseholdVC = self.dependencyView.createHouseholdVC()
                        let navVC = UINavigationController(rootViewController: createHouseholdVC)
                        self.switchToViewController(navVC)
                    }
                    else {
                        let landingVC = self.dependencyView.landingVC()
                        let navVC = UINavigationController(rootViewController: landingVC)
                        self.switchToViewController(navVC)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func switchToViewController(_ newVC: UINavigationController) {
        guard let newRoot = newVC.viewControllers.first,
              let oldRoot = current.viewControllers.first,
              type(of: newRoot) != type(of: oldRoot) 
        else{
            return
        }
        let oldVC = current
        // Prepare the new view controller
        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newVC.view)
        setupConstraints(for: newVC.view)
        newVC.didMove(toParent: self)
        oldVC.willMove(toParent: nil)
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParent()
        
        // Update the current view controller reference
        current = newVC
    }
    
    private func setupConstraints(for childView: UIView) {
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.topAnchor.constraint(equalTo: view.topAnchor),
            childView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

