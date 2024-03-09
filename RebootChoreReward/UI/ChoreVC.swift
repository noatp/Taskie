//
//  ChoreVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI
import Combine

class ChoreVC: UIViewController {
    private var chores = [Chore]()
    private var cancellables: Set<AnyCancellable> = []
    
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubscription()
        setUpViews()
        setUpActions()
    }
    
    private func addSubscription() {
        ChoreFirestoreService.shared.chores.sink { [weak self] chores in
            self?.chores = chores
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
        Task {
            do {
                try await ChoreFirestoreService.shared.createChore(withChore: Chore(name: "Test Chore", creator: "Me"))
                // Optionally, handle any UI updates or confirmations here
            } catch {
                print("Error creating chore: \(error)")
                // Handle errors, perhaps by showing an alert to the user
            }
        }
    }
}

extension ChoreVC: UITableViewDelegate {
    
}

extension ChoreVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        cell.textLabel?.text = chores[indexPath.row].name
        return cell
    }
}

struct ChoreVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            UINavigationController(rootViewController: ChoreVC())
        }
    }
}

