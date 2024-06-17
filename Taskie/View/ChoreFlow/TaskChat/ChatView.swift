//
//  ChatView.swift
//  Taskie
//
//  Created by Toan Pham on 6/12/24.
//

import SwiftUI
import Combine

struct ChatView: View {
    @ObservedObject var viewModel: TaskChatViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @State private var dynamicHeight: CGFloat = 44
    @FocusState private var isInputFocused: Bool
    @State private var presentImagePicker: Bool = false
    @State private var showFinishView: Bool = false

    var body: some View {
        VStack (spacing: 0) {
            ScrollViewReader { proxy in
                List(viewModel.chatMessages) { message in
                    ChatMessageView(message: message)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .id(message.id)
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.chatMessages) { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy, shouldAnimate: true)
                    }
                }
                .onChange(of: viewModel.images.count) { _, _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy, shouldAnimate: true)
                    }
                }
//                .onChange(of: isInputFocused) { _, _ in
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                        scrollToBottom(proxy: proxy, shouldAnimate: true)
//                    }
//                }
            }
            Spacer(minLength: 10)

            PDSImageSelectionRowView(presentImagePicker: $presentImagePicker, images: $viewModel.images)
                .frame(height: shouldShowImageRow ? 100 : 0)
                .padding(shouldShowImageRow ? 10 : 0)
                .background(Color(themeManager.currentTheme.color.backgroundColor))
            HStack {
                if (!isInputFocused) {
                    
                    if !actionButtonTitle.isEmpty {
                        Button(action: {
                            handleActionButton()
                        }) {
                            Text(actionButtonTitle)
                                .padding(10)
                                .background(Color(themeManager.currentTheme.color.primaryColor))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .fullScreenCover(isPresented: $showFinishView) {
                            FinishView()
                        }
                    }
                    
                    Button(action: {
                        presentImagePicker = true
                    }) {
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .padding(5)
                            .foregroundColor(Color(themeManager.currentTheme.color.primaryColor))
                    }
                }
                else {
                    Button(action: {
                        viewModel.createNewMessage()
                        isInputFocused = false
                    }) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(10)
                            .foregroundColor(Color(themeManager.currentTheme.color.primaryColor))
                    }
                }
                

                PDSTextViewWrapper(text: $viewModel.chatInputText, placeholder: "Message", dynamicHeight: $dynamicHeight)
                    .frame(height: dynamicHeight)
                    .focused($isInputFocused)

                Button(action: {
                    viewModel.createNewMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .padding(10)
                        .foregroundColor(isSendButtonDisabled ? .gray : Color(themeManager.currentTheme.color.primaryColor))
                }
                .disabled(isSendButtonDisabled)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color(themeManager.currentTheme.color.backgroundColor))
            .animation(.snappy, value: isInputFocused)
        }
        .ignoresSafeArea()
    }

    private func scrollToBottom(proxy: ScrollViewProxy, shouldAnimate: Bool = false) {
        if let lastMessage = viewModel.chatMessages.last {
            withAnimation(shouldAnimate ? .smooth : nil) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private var isSendButtonDisabled: Bool {
        return viewModel.chatInputText.isEmpty
    }
    
    private var shouldShowImageRow: Bool {
        return !viewModel.images.isEmpty
    }
    
    private var actionButtonTitle: String {
        switch viewModel.choreDetail?.actionButtonType {
        case .accept:
            "Accept"
        case .finish:
            "Finish"
        case .withdraw:
            "Withdraw"
        case .nothing:
            ""
        case nil:
            ""
        }
    }
    
    private func handleActionButton() {
        switch viewModel.choreDetail?.actionButtonType {
        case .accept:
            viewModel.acceptSelectedChore()
        case .finish:
            showFinishView = true
        case .withdraw:
            viewModel.withdrawSelectedChore()
        case .nothing:
            break
        case nil:
            break
        }
    }
}
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: Dependency.preview.viewModel.taskChatViewModel())
            .environmentObject(ThemeManager.shared)
    }
}
