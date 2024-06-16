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

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                List(viewModel.chatMessages) { message in
                    ChatMessageView(message: message)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .id(message.id)
                }
                .listStyle(PlainListStyle())
                .onAppear {
                    // Scroll to the bottom on appear
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy)
                    }
                }
                .onChange(of: viewModel.chatMessages) { _, _ in
                    // Scroll to the bottom when a new message is added
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
            
            PDSImageSelectionRowView(presentImagePicker: $presentImagePicker, images: $viewModel.images)
                .frame(height: viewModel.images.isEmpty ? 0 : 100)
                .padding(.horizontal, 10)

            HStack {
                if (!isInputFocused) {
                    Button(action: {
                        print("Withdraw button tapped.")
                    }) {
                        Text("Withdraw")
                            .padding(10)
                            .background(Color(themeManager.currentTheme.color.primaryColor))
                            .foregroundColor(.white)
                            .cornerRadius(10)
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
                    .focused($isInputFocused) // Bind the focus state to the input field

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
}
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: Dependency.preview.viewModel.taskChatViewModel())
            .environmentObject(ThemeManager.shared)
    }
}
//
//final class KeyboardResponder: ObservableObject {
//    @Published var isKeyboardShowing: Bool = false
//    private var cancellable: AnyCancellable?
//    
//    init() {
//        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
//            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
//            .compactMap { notification in
//                if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//                    return notification.name == UIResponder.keyboardWillHideNotification ? false : true
//                }
//                return nil
//            }
//            .assign(to: \.isKeyboardShowing, on: self)
//    }
//}
