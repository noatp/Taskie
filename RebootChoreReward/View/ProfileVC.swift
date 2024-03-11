//
//  ProfileVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class ProfileVC: UIViewController {
    private var viewModel: ProfileViewModel
    
    let signOutButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Sign out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: ProfileViewModel = .init()) {
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
        view.backgroundColor = .systemBackground

        view.addSubview(signOutButton)
        NSLayoutConstraint.activate([
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setUpActions() {
        signOutButton.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
    }
    
    @objc func handleSignOut() {
        viewModel.signOut()
    }
}

struct ProfileVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            ProfileVC()
        }
    }
}
