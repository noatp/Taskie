//
//  ProfileVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class ProfileVC: UIViewController {
    let signOutButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton(type: .system)
        button.setTitle("Sign out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
        AuthService.shared.signOut()
    }
}

struct ProfileVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            ProfileVC()
        }
    }
}
