//
//  ProfileVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class MenuVC: PDSTitleWrapperVC {
    private var viewModel: MenuViewModel
    private let dependencyView: Dependency.View
    
    private let menuOptions = [
        ("Reward", "Check reward balance"),
        ("Household", "View household members, invite new members"),
        ("Profile", "Edit your profile details")
    ]
    
    private let signOutButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Sign out", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.left")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuOptionTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.className)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(
        viewModel: MenuViewModel,
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
                
        menuOptionTableView.delegate = self
        menuOptionTableView.dataSource = self

        view.addSubview(menuOptionTableView)
        view.addSubview(signOutButton)
        NSLayoutConstraint.activate([
            menuOptionTableView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            menuOptionTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuOptionTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuOptionTableView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor, constant: -40),
            
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signOutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
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
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension MenuVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let selectedOption = menuOptions[indexPath.row]
        
        switch selectedOption.0 {
        case "Reward":
            let rewardBalanceVC = dependencyView.rewardBalanceVC()
            navigationController?.pushViewController(rewardBalanceVC, animated: true)
        case "Household":
            let memberListVC = dependencyView.householdMemberListVC()
            navigationController?.pushViewController(memberListVC, animated: true)
        case "Profile":
            break
        default:
            break
        }
    }
}

extension MenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.className, for: indexPath) as? MenuCell else {
            return UITableViewCell()
        }
        let menuOption = menuOptions[indexPath.row]
        cell.configureCell(withOption: menuOption.0, optionDescription: menuOption.1)
        return cell
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
            viewModel: viewModel.menuViewModel(),
            dependencyView: self
        )
    }
}
