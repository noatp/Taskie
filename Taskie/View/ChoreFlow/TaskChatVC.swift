
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
    
    private var chatView: ChatView
    
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
        self.chatView = ChatView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setUpViews()
    }
    
    private func bindViewModel() {
        viewModel.$choreDetail
            .receive(on: RunLoop.main)
            .sink { [weak self] chore in
                guard let chore = chore,
                      let self = self
                else {
                    return
                }
                setTitle(chore.name)
                //                updateActionButton(for: chore.actionButtonType)
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        let hostingController = UIHostingController(rootView: chatView)
        guard let hostingControllerView = hostingController.view else {
            return
        }
        addChild(hostingController)
        view.addSubview(hostingControllerView)
        hostingControllerView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            hostingControllerView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            hostingControllerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingControllerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingControllerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        
    }
    
    //    @objc func handleBack() {
    //        navigationController?.popViewController(animated: true)
    //    }
    //
    //    @objc func submitMessage() {
    //        viewModel.createNewMessage(chatTextView.text)
    //        chatTextView.text = ""
    //        revertActionButton()
    //    }
    //
    //    @objc func handleChevronButton() {
    //        revertActionButton()
    //    }
    //
    //    @objc func handleActionButton() {
    //        if let chore = viewModel.choreDetail {
    //            switch chore.actionButtonType {
    //                case .accept:
    //                    break
    //                case .finish:
    //                    break
    //                case .withdraw:
    //                    break
    //                case .nothing:
    //                    break
    //            }
    //        }
    //    }
    //
    //    func scrollToBottom(animated: Bool) {
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
    //            let numberOfSections = self.tableView.numberOfSections
    //            let numberOfRows = self.tableView.numberOfRows(inSection: numberOfSections - 1)
    //
    //            guard numberOfSections > 0, numberOfRows > 0 else {
    //                return
    //            }
    //
    //            // Scroll to the last row
    //            let indexPath = IndexPath(row: numberOfRows - 1, section: numberOfSections - 1)
    //            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    //
    //            // Scroll to the bottom to include footer view
    //            if let footerView = self.tableView.tableFooterView {
    //                let contentHeight = self.tableView.contentSize.height
    //                let frameHeight = self.tableView.frame.height
    //                if contentHeight > frameHeight {
    //                    let bottomOffset = CGPoint(x: 0, y: contentHeight - frameHeight)
    //                    self.tableView.setContentOffset(bottomOffset, animated: animated)
    //                }
    //            }
    //        }
    //    }
    //
    //    private func updateActionButtonForEditing() {
    //        isEditingChatTextView = true
    //        actionButton.setTitle("", for: .normal)
    //        actionButton.isHidden = true
    //        chevronButton.isHidden = false
    //        UIView.animate(withDuration: 0.2) { [weak self] in
    //            self?.view.layoutIfNeeded()
    //        }
    //    }
    //
    //    private func revertActionButton() {
    //        isEditingChatTextView = false
    //        actionButton.isHidden = false
    //        chevronButton.isHidden = true
    //        if let chore = viewModel.choreDetail {
    //            updateActionButton(for: chore.actionButtonType)
    //        }
    //        UIView.animate(withDuration: 0.2) { [weak self] in
    //            self?.view.layoutIfNeeded()
    //        }
    //    }
    //
    //    private func updateActionButton(for type: Chore.ActionButtonType) {
    //        switch type {
    //            case .accept:
    //                actionButton.isHidden = false
    //                actionButton.setTitle("Accept", for: .normal)
    //            case .finish:
    //                actionButton.isHidden = false
    //                actionButton.setTitle("Finished", for: .normal)
    //            case .withdraw:
    //                actionButton.isHidden = false
    //                actionButton.setTitle("Withdraw", for: .normal)
    //            case .nothing:
    //                actionButton.isHidden = true
    //        }
    //    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

//extension TaskChatVC: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
//}
//
//extension TaskChatVC: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return viewModel.chatMessages.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let chatMessage = viewModel.chatMessages[indexPath.row]
//
//        if chatMessage.isFromCurrentUser {
//            if chatMessage.imageUrls.isEmpty {
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: OutgoingChatMessageCell.className, for: indexPath) as? OutgoingChatMessageCell else {
//                    return UITableViewCell()
//                }
//                cell.configureCell(with: chatMessage)
//                return cell
//            } else {
//                guard let cell = tableView.dequeueReusableCell(withIdentifier: OutgoingChatMessageCellWithImage.className, for: indexPath) as? OutgoingChatMessageCellWithImage else {
//                    return UITableViewCell()
//                }
//                cell.configureCell(with: chatMessage)
//                return cell
//            }
//        } else {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: IncomingChatMessageCell.className, for: indexPath) as? IncomingChatMessageCell else {
//                return UITableViewCell()
//            }
//            cell.configureCell(with: chatMessage)
//            return cell
//        }
//    }
//}

//extension TaskChatVC: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        scrollToBottom(animated: true)
//    }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        revertActionButton()
//    }
//
//    func textViewDidChange(_ textView: UITextView) {
//        if !isEditingChatTextView {
//            updateActionButtonForEditing()
//        }
//
//        let size = chatTextView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
//        chatTextView.isScrollEnabled = size.height > chatTextViewMaxHeight
//        self.chatTextViewHeightConstraint.constant = min(size.height, self.chatTextViewMaxHeight)
//        UIView.animate(withDuration: 0.1) { [weak self] in
//            self?.view.layoutIfNeeded()
//        }
//    }
//}


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


struct ChatView: View {
    @ObservedObject var viewModel: TaskChatViewModel
    
    var body: some View {
        VStack {
            List(viewModel.chatMessages) { message in
                ChatMessageView(message: message)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
            }
            .listStyle(PlainListStyle())
            
            HStack {
                Button(action: {
                    print("Withdraw button tapped.")
                }) {
                    Text("Withdraw")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                TextField("Message", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    print("Send button tapped.")
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .padding()
        }
        
        .onReceive(viewModel.$chatMessages) { chatMessages in
            print("Chat messages updated: \(chatMessages.count)")
        }
    }
}

struct ChatMessageView: View {
    var message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            if message.isFromCurrentUser {
                Spacer()
                ChatBubble(message: message)
                UserImage(profileColor: message.sender.profileColor)
                    .opacity(message.isFirstInSequence ? 1 : 0)
                
            }
            else {
                UserImage(profileColor: message.sender.profileColor)
                    .opacity(message.isFirstInSequence ? 1 : 0)
                ChatBubble(message: message)
                Spacer()
            }
        }
        .padding(.top, message.isFirstInSequence ? 20 : 5)
        .padding(message.isFromCurrentUser ? .trailing : .leading, 10)
        //        VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
        //            if message.isFirstInSequence {
        //                HStack {
        //                    if message.isFromCurrentUser {
        //                        Spacer()
        //                        Text(message.sender.name ?? "")
        //                            .font(.caption)
        //                            .foregroundColor(.gray)
        //                        Text(message.sendDate)
        //                            .font(.caption)
        //                            .foregroundColor(.gray)
        //                    }
        //
        //
        //                    else {
        //                        Text(message.sender.name ?? "")
        //                            .font(.caption)
        //                            .foregroundColor(.gray)
        //                        Text(message.sendDate)
        //                            .font(.caption)
        //                            .foregroundColor(.gray)
        //                        Spacer()
        //                    }
        //                }
        //            }
        //
        //            HStack(alignment: .top) {
        //                if message.isFromCurrentUser {
        //                    Spacer()
        //                }
        //
        ////                if message.type == .request {
        ////                    Image("question-mark", bundle: .main)
        ////                        .frame(width: 40, height: 60)
        ////                        .foregroundColor(.yellow)
        ////                }
        //
        //                VStack(alignment: .leading, spacing: 4) {
        //                    Text(message.message)
        //                        .padding()
        //                        .background(message.isFromCurrentUser ? Color.green : Color.gray.opacity(0.2))
        //                        .cornerRadius(10)
        //                        .foregroundColor(message.isFromCurrentUser ? .white : .black)
        //
        //                    if !message.imageUrls.isEmpty {
        //                        ForEach(message.imageUrls, id: \.self) { imageUrl in
        //                            AsyncImage(url: URL(string: imageUrl)) { image in
        //                                image.resizable()
        //                                    .scaledToFill()
        //                                    .frame(height: 200)
        //                                    .cornerRadius(10)
        //                            } placeholder: {
        //                                ProgressView()
        //                            }
        //                        }
        //                    }
        //                }
        //
        //                if message.isFromCurrentUser {
        //                    Image(systemName: "smiley.fill")
        //                        .foregroundColor(.yellow)
        //                }
        //
        //                if !message.isFromCurrentUser {
        //                    Spacer()
        //                }
        //            }
        //
        //            if message.isLastInSequence {
        //                Spacer().frame(height: 10)
        //            }
        //        }
        //        .padding(message.isFromCurrentUser ? .leading : .trailing, 60)
        //        .padding(message.isFromCurrentUser ? .trailing : .leading, 16)
    }
}

struct ChatBubble: View {
    var message: ChatMessage
    var body: some View {
        VStack(alignment: .leading) {
            if message.isFirstInSequence {
                HStack {
                    Text(message.sender.name ?? "")
                    Text(message.sendDate)
                }
            }
            Text(message.message)
            if !message.imageUrls.isEmpty {
                GeometryReader { geometry in
                    ImageGridView(imageUrls: message.imageUrls, width: geometry.size.width)
                        .padding(.top, 10)
                }
                .frame(height: (UIScreen.main.bounds.width * 0.7)) // Adjust height as needed
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10.0)
                .fill(message.isFromCurrentUser ? .green : .gray)
        )
        .frame(
            maxWidth: UIScreen.main.bounds.width * 0.7,
            alignment: message.isFromCurrentUser ? .trailing : .leading
        )
    }
}

struct UserImage: View {
    var profileColor: String?
    
    var body: some View {
        Image("smileyFace", bundle: .main)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .background(
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(Color(uiColor: .init(hex: profileColor)))
            )
    }
    
}

struct ImageGridView: View {
    let imageUrls: [String]
    let width: CGFloat
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        let sideLength = (width - 8) / 2 // Adjust spacing as needed
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(imageUrls, id: \.self) { imageUrl in
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: sideLength, height: sideLength)
                        .clipped()
                        .cornerRadius(10)
                } placeholder: {
                    ProgressView()
                        .frame(width: sideLength, height: sideLength)
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: Dependency.preview.viewModel.taskChatViewModel())
    }
}




