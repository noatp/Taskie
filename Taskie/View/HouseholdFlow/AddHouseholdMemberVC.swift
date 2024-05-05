
//  AddHouseholdMemberVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/14/24.
//

import SwiftUI
import UIKit
import Combine

class AddHouseholdMemberVC: PDSTitleWrapperVC {
    private var viewModel: AddHouseholdMemberViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private let promptLabel: PDSLabel = {
        let label = PDSLabel(withText: "To add a family member into this Household:", fontScale: .caption)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let promptBulletsLabel: PDSLabel = {
        let label = PDSLabel(withText: "\u{2022} have them download the app, and go through sign up process\n\u{2022} provide them with the following 6 digit invite code", fontScale: .body)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let inviteCodeLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline2)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "xmark")
        return button
    }()
    
    init(viewModel: AddHouseholdMemberViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        
    }

    private func setUpViews() {
        setTitle("Add member")
        
        view.addSubview(promptLabel)
        view.addSubview(promptBulletsLabel)
        view.addSubview(inviteCodeLabel)
        
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            promptBulletsLabel.topAnchor.constraint(equalTo: promptLabel.bottomAnchor),
            promptBulletsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            promptBulletsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            inviteCodeLabel.topAnchor.constraint(equalTo: promptBulletsLabel.bottomAnchor, constant: 40),
            inviteCodeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func setUpActions() {
        cancelBarButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBarButton)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    override func applyTheme(_ theme: PDSTheme) {
        super.applyTheme(theme)
        view.backgroundColor = theme.color.surfaceColor
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

struct AddHouseholdMemberVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            let baseVC = UIViewController()
            let addHouseholdMemberVC = Dependency.preview.view.addHouseholdMemberVC()
            let navVC = UINavigationController(rootViewController: addHouseholdMemberVC)
            DispatchQueue.main.async {
                baseVC.present(navVC, animated: true, completion: nil)
            }
            
            return baseVC
        }
    }
}

extension Dependency.View {
    func addHouseholdMemberVC() -> AddHouseholdMemberVC {
        return AddHouseholdMemberVC(viewModel: viewModel.addHouseholdMemberViewModel())
    }
}
