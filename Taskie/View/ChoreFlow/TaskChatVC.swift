
//  TaskChatVC.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import SwiftUI
import UIKit
import Combine

class TaskChatVC: PDSResizeWithKeyboardVC {
    private var viewModel: TaskChatViewModel
    private let dependencyView: Dependency.View
    private var cancellables: Set<AnyCancellable> = []
    
    var chatTextViewHeightConstraint: NSLayoutConstraint!
    var chatTextViewMaxHeight: CGFloat!
    
    private let chatTextView: PDSTextView = {
        let textView = PDSTextView()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.placeholder = "Message"
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.className)
        return tableView
    }()
    
    private let backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.left")
        return button
    }()
    
    init(
        viewModel: TaskChatViewModel,
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
        bindViewModel()
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        viewModel.$chatMessages
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$choreDetail
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        setTitle("Details")
        tableView.dataSource = self
        tableView.delegate = self
        
        chatTextView.delegate = self
        
        let lineHeight = chatTextView.font?.lineHeight ?? 0
        chatTextViewMaxHeight = lineHeight * CGFloat(4)
        
        view.addSubview(tableView)
        view.addSubview(chatTextView)
        
        chatTextViewHeightConstraint = chatTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 37)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            chatTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            chatTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chatTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            chatTextViewHeightConstraint,
            constraintViewToKeyboard(chatTextView)
        ])
    }

    private func setUpActions() {
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

extension TaskChatVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension TaskChatVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.className, for: indexPath) as? ChatMessageCell else {
            return UITableViewCell()
        }
        let chatMessage = viewModel.chatMessages[indexPath.row]
        cell.configureCell(with: chatMessage)
        return cell
    }
}

extension TaskChatVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = chatTextView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        chatTextView.isScrollEnabled = size.height > chatTextViewMaxHeight
        self.chatTextViewHeightConstraint.constant = min(size.height, self.chatTextViewMaxHeight)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

struct TaskChatVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.taskChatVC()
        }
    }
}
 
extension Dependency.View {
    func taskChatVC() -> TaskChatVC {
        return TaskChatVC(
            viewModel: viewModel.taskChatViewModel(),
            dependencyView: self
        )
    }
}
