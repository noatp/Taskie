//
//  ProfileVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class MenuVC: PDSTitleWrapperVC {
    private var viewModel: ProfileViewModel
    private let dependencyView: Dependency.View
    
    let signOutButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Sign out", for: .normal)
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
        viewModel: ProfileViewModel,
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
        setTitle("Menu")
        
        view.backgroundColor = .systemBackground

        view.addSubview(signOutButton)
        NSLayoutConstraint.activate([
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setUpActions() {
        signOutButton.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleSignOut() {
        viewModel.signOut()
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

struct MenuVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.menuVC()
        }
    }
}

extension Dependency.View {
    func menuVC() -> MenuVC {
        return MenuVC (
            viewModel: viewModel.profileViewModel(),
            dependencyView: self
        )
    }
}
