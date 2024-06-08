
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
    var isEditingChatTextView: Bool = false
    
    private let sendButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "paperplane.fill", alignment: .center)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let chevronButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.right", alignment: .center)
        button.isHidden = true
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
            .sink { [weak self] chore in
                guard let chore = chore,
                      let self = self
                else {
                    return
                }
                setTitle(chore.name)
                updateActionButton(for: chore.actionButtonType)
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        tableView.dataSource = self
        tableView.delegate = self
        
        chatTextView.delegate = self
        
        let lineHeight = chatTextView.font?.lineHeight ?? 0
        chatTextViewMaxHeight = lineHeight * CGFloat(4)
        
        view.addSubview(tableView)
        view.addSubview(chatTextView)
        view.addSubview(sendButton)
        view.addSubview(actionButton)
        view.addSubview(chevronButton)
        
        chatTextViewHeightConstraint = chatTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 37)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.centerYAnchor.constraint(equalTo: chatTextView.centerYAnchor),
            
            chevronButton.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 10),
            chevronButton.centerYAnchor.constraint(equalTo: chatTextView.centerYAnchor),
            
            chatTextView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 10),
            chatTextView.leadingAnchor.constraint(equalTo: actionButton.trailingAnchor, constant: 10),
            chatTextView.leadingAnchor.constraint(equalTo: chevronButton.trailingAnchor, constant: 5),
            chatTextView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -5),
            chatTextViewHeightConstraint,
            constraintViewToKeyboard(chatTextView),
            
            sendButton.centerYAnchor.constraint(equalTo: chatTextView.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
        
        actionButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }

    private func setUpActions() {
        chevronButton.addTarget(self, action: #selector(handleChevronButton), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
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
        revertActionButton()
    }
    
    @objc func handleChevronButton() {
        revertActionButton()
    }
    
    @objc func handleActionButton() {
        if let chore = viewModel.choreDetail {
            switch chore.actionButtonType {
                case .accept:
                    break
//                    viewModel.acceptSelectedChore()
                case .finish:
                    //                viewModel.finishedSelectedChore()
//                    let submitChoreVC = dependencyView.submitChoreVC()
//                    self.navigationController?.pushViewController(submitChoreVC, animated: true)
                    break
                case .withdraw:
                    break
//                    viewModel.withdrawSelectedChore()
                case .nothing:
                    break
            }
        }
    }
    
    func scrollToBottom(animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections - 1)
            
            guard numberOfSections > 0, numberOfRows > 0 else {
                return
            }
            
            let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }

    
    private func updateActionButtonForEditing() {
        isEditingChatTextView = true
        actionButton.setTitle("", for: .normal)
        actionButton.isHidden = true
        chevronButton.isHidden = false
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func revertActionButton() {
        isEditingChatTextView = false
        actionButton.isHidden = false
        chevronButton.isHidden = true
        if let chore = viewModel.choreDetail {
            updateActionButton(for: chore.actionButtonType)
        }
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    private func updateActionButton(for type: Chore.ActionButtonType) {
        switch type {
            case .accept:
                actionButton.isHidden = false
                actionButton.setTitle("Accept", for: .normal)
                actionButton.setImage(nil, for: .normal)
            case .finish:
                actionButton.isHidden = false
                actionButton.setTitle("Finished", for: .normal)
                actionButton.setImage(nil, for: .normal)
            case .withdraw:
                actionButton.isHidden = false
                actionButton.setTitle("Withdraw", for: .normal)
                actionButton.setImage(nil, for: .normal)
            case .nothing:
                actionButton.isHidden = true
        }
    }
    
    override func applyTheme(_ theme: PDSTheme) {
        super.applyTheme(theme)
        sendButton.tintColor = theme.color.primaryColor
        actionButton.setTitleColor(theme.color.primaryColor, for: .normal)
        actionButton.tintColor = theme.color.primaryColor
    }
    
    deinit {
        LogUtil.log("deinit")
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollToBottom(animated: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        revertActionButton()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if !isEditingChatTextView {
            updateActionButtonForEditing()
        }

        let size = chatTextView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        chatTextView.isScrollEnabled = size.height > chatTextViewMaxHeight
        self.chatTextViewHeightConstraint.constant = min(size.height, self.chatTextViewMaxHeight)
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.view.layoutIfNeeded()
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
