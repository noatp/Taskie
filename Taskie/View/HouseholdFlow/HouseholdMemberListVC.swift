
//  HouseholdMemberListVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/8/24.
//

import SwiftUI
import UIKit
import Combine

class HouseholdMemberListVC: PDSTitleWrapperVC {
    private var viewModel: HouseholdMemberListViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let depedencyView: Dependency.View
    
    private let tableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.left")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "plus", alignment: .trailing)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: HouseholdMemberListViewModel,
        depedencyView: Dependency.View
    ) {
        self.viewModel = viewModel
        self.depedencyView = depedencyView
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
        viewModel.$familyMembers
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        setTitle("Household")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setUpActions() {
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        addBarButton.addTarget(self, action: #selector(addNewItem), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addNewItem() {
        let addHouseholdMemberVC = depedencyView.addHouseholdMemberVC()
        let navVC = UINavigationController(rootViewController: addHouseholdMemberVC)
        self.present(navVC, animated: true)
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension HouseholdMemberListVC: UITableViewDelegate {
    
}

extension HouseholdMemberListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.familyMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.familyMembers[indexPath.row].name
        return cell
    }
    
    
}

struct HouseholdMemberListVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            UINavigationController(rootViewController: Dependency.preview.view.householdMemberListVC())
                                   
        }
    }
}

extension Dependency.View {
    func householdMemberListVC() -> HouseholdMemberListVC {
        return HouseholdMemberListVC(
            viewModel: viewModel.householdMemberListViewModel(), depedencyView: self
        )
    }
}

 
