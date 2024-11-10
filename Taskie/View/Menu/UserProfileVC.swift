
//  UserProfileVC.swift
//  Taskie
//
//  Created by Toan Pham on 11/10/24.
//

import SwiftUI
import UIKit

class UserProfileVC: PDSTitleWrapperVC {
    private var viewModel: UserProfileViewModel
    private let dependencyView: Dependency.View

    private let backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.left")
        return button
    }()
    
    init(
        viewModel: UserProfileViewModel,
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
        setTitle("Title")
    }

    private func setUpActions() {
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

struct UserProfileVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.userProfileVC()
        }
    }
}
 
extension Dependency.View {
    func userProfileVC() -> UserProfileVC {
        return UserProfileVC(
            viewModel: viewModel.userProfileViewModel(),
            dependencyView: self
        )
    }
}
