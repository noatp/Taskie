//
//  ChoreListVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI
import Combine
 
class ChoreListVC: UIViewController {
    private var viewModel: ChoreListViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let depedencyView: Dependency.View
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(PDSChoreCell.self, forCellReuseIdentifier: PDSChoreCell.className)
        return tableView
    }()
    
    init(
        viewModel: ChoreListViewModel,
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
        viewModel.$chores
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        view.backgroundColor = .systemBackground
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem))
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setUpActions() {
        
    }
    
    @objc func addNewItem() {
        let addChoreVC = depedencyView.addChoreVC()
        self.present(addChoreVC, animated: true)
    }
}

extension ChoreListVC: UITableViewDelegate {
    
}

extension ChoreListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PDSChoreCell.className, for: indexPath) as? PDSChoreCell else {
            return UITableViewCell()
        }
        cell.configureCell(withChore: viewModel.chores[indexPath.row])
        return cell
    }
}

struct ChoreListVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            UINavigationController(
                rootViewController: Dependency.preview.view.choreListVC()
            )
        }
    }
}

extension Dependency.View {
    func choreListVC() -> ChoreListVC {
        return ChoreListVC(
            viewModel: viewModel.choreListViewModel(),
            depedencyView: self
        )
    }
}

