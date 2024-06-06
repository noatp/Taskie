
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
    
    private let sendButton: UIButton = {
        let button = UIButton()
        let sendImage = UIImage(systemName: "paperplane.fill")
        button.setImage(sendImage, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        tableView.register(OutoingChatMessageCell.self, forCellReuseIdentifier: OutoingChatMessageCell.className)
        tableView.register(IncomingChatMessageCell.self, forCellReuseIdentifier: IncomingChatMessageCell.className)
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
                self?.scrollToBottom(animated: false)
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
        view.addSubview(sendButton)
        
        chatTextViewHeightConstraint = chatTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 37)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            chatTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            chatTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            chatTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -20),
            chatTextViewHeightConstraint,
            constraintViewToKeyboard(chatTextView),
            
            sendButton.centerYAnchor.constraint(equalTo: chatTextView.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setUpActions() {
        sendButton.addTarget(self, action: #selector(submitMessage), for: .touchUpInside)
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func submitMessage() {
        viewModel.createNewMessage(chatTextView.text)
        chatTextView.text = ""
    }
    
    func scrollToBottom(animated: Bool) {
        let numberOfSections = tableView.numberOfSections
        let numberOfRows = tableView.numberOfRows(inSection: numberOfSections - 1)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    override func applyTheme(_ theme: PDSTheme) {
        super.applyTheme(theme)
        sendButton.tintColor = theme.color.primaryColor
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
        let chatMessage = viewModel.chatMessages[indexPath.row]
        
        if chatMessage.isFromCurrentUser {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OutoingChatMessageCell.className, for: indexPath) as? OutoingChatMessageCell else {
                return UITableViewCell()
            }
            cell.configureCell(with: chatMessage)
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: IncomingChatMessageCell.className, for: indexPath) as? IncomingChatMessageCell else {
                return UITableViewCell()
            }
            cell.configureCell(with: chatMessage)
            return cell
        }
        
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
