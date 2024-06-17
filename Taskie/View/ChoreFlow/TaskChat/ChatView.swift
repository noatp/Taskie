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
    @State private var showFinishView: Bool = false
    @State private var shouldShowButtonGroup: Bool = true
    @State private var isImagePickerPresented = false
    @State private var isCamera = false
    @State private var isActionSheetPresented = false
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
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
            }
            Spacer(minLength: 10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.images, id: \.self) { image in
                        ImageThumbnail(image: image) {
                            withAnimation {
                                viewModel.removeImage(image: image)
                            }
                        }
                    }
                }
            }
            .padding(shouldShowImageRow ? 10 : 0)
            .background(Color(themeManager.currentTheme.color.backgroundColor))
            
            HStack {
                if shouldShowButtonGroup {
                    ActionButtons
                } else {
                    ToggleButton
                }
                
                PDSTextViewWrapper(text: $viewModel.chatInputText, placeholder: "Message", dynamicHeight: $dynamicHeight)
                    .frame(height: dynamicHeight)
                    .onChange(of: viewModel.chatInputText) { _, _ in
                        shouldShowButtonGroup = false
                    }
                
                SendButton
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color(themeManager.currentTheme.color.backgroundColor))
            .animation(.snappy, value: shouldShowButtonGroup)
        }
        .ignoresSafeArea()
        .actionSheet(isPresented: $isActionSheetPresented) {
            ActionSheet(
                title: Text("Choose an option"),
                buttons: [
                    .default(Text("Select Photo")) {
                        isCamera = false
                        isImagePickerPresented = true
                    },
                    .default(Text("Take Photo")) {
                        isCamera = true
                        isImagePickerPresented = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(image: $selectedImage, sourceType: isCamera ? .camera : .photoLibrary)
                .ignoresSafeArea()
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let newImage = newValue, newImage != oldValue {
                viewModel.images.append(newImage)
            }
        }
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
    
    private var isAddImageButtonDisabled: Bool {
        return viewModel.images.count > 3
    }
    
    private var actionButtonTitle: String {
        switch viewModel.choreDetail?.actionButtonType {
        case .accept:
            return "Accept"
        case .finish:
            return "Finish"
        case .withdraw:
            return "Withdraw"
        case .nothing, nil:
            return ""
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
        case .nothing, nil:
            break
        }
    }
    
    private var ActionButtons: some View {
        HStack {
            if !actionButtonTitle.isEmpty {
                Button(action: handleActionButton) {
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
                isActionSheetPresented = true
            }) {
                Image(systemName: "photo.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .padding(5)
                    .foregroundColor(isAddImageButtonDisabled ? .gray : Color(themeManager.currentTheme.color.primaryColor))
            }
            .disabled(isAddImageButtonDisabled)
        }
    }
    
    private var ToggleButton: some View {
        Button(action: {
            shouldShowButtonGroup = true
        }) {
            Image(systemName: "chevron.right")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(10)
                .foregroundColor(Color(themeManager.currentTheme.color.primaryColor))
        }
    }
    
    private var SendButton: some View {
        Button(action: {
            viewModel.createNewMessage()
        }) {
            if viewModel.isSendingMessage {
                ProgressView()
                    .frame(width: 44, height: 44)
            }
            else {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24, height: 24)
                    .padding(10)
                    .foregroundColor(isSendButtonDisabled ? .gray : Color(themeManager.currentTheme.color.primaryColor))
            }
        }
        .disabled(isSendButtonDisabled || viewModel.isSendingMessage)
    }
}

struct ImageThumbnail: View {
    var image: UIImage
    var removeAction: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
            Button(action: removeAction) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.7)))
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: Dependency.preview.viewModel.taskChatViewModel())
            .environmentObject(ThemeManager.shared)
    }
}

