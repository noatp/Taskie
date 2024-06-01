//
//  ChoreListVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI
import Combine
 
class ChoreListVC: PDSTitleWrapperVC {
    private var viewModel: ChoreListViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let depedencyView: Dependency.View
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.register(ChoreCell.self, forCellReuseIdentifier: ChoreCell.className)
        return tableView
    }()
    
    private let menuBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "line.3.horizontal")
        return button
    }()
    
    private let addBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "plus", alignment: .trailing)
        return button
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
        setUpBarButtons()
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
        setTitle("Tasks")
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setUpActions() {
        menuBarButton.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        addBarButton.addTarget(self, action: #selector(addNewItem), for: .touchUpInside)
    }
    
    private func setUpBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuBarButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addBarButton)
    }
    
    @objc func addNewItem() {
        let addChoreVC = depedencyView.addChoreVC()
        let navVC = UINavigationController(rootViewController: addChoreVC)
        self.present(navVC, animated: true)
    }
    
    @objc func showMenu() {
        let profileVC = depedencyView.menuVC()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension ChoreListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        viewModel.readSelectedChore(choreId: viewModel.chores[indexPath.row].id)
        let choreDetailVC = depedencyView.choreDetailVC()
        self.navigationController?.pushViewController(choreDetailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
}

extension ChoreListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChoreCell.className, for: indexPath) as? ChoreCell else {
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

