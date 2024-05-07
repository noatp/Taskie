
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
    
    private let inviteButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Invite", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        view.addSubview(inviteButton)
        
        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            inviteButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            inviteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setUpActions() {
        cancelBarButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBarButton)
        inviteButton.addTarget(self, action: #selector(handleInvite), for: .touchUpInside)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    @objc func handleInvite() {
        shareInviteLink()
    }
    
    func shareInviteLink() {
        guard let inviteLink = viewModel.getInviteLink() else {
            return
        }
        let text = "Use this invite link to download Taskie and join the household: \(inviteLink)"
        let items = [text]
        
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(activityViewController, animated: true)
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
