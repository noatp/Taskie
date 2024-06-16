//
//  ChatView.swift
//  Taskie
//
//  Created by Toan Pham on 6/12/24.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: TaskChatViewModel
    @EnvironmentObject var themeManager: ThemeManager
    
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
                        .padding(10)
                        .background(Color(themeManager.currentTheme.color.primaryColor))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                PDSTextViewWrapper(text: $viewModel.chatInputText, placeholder: "Message")
                    .frame(height: 44)
                
                Button(action: {
                    print("Send button tapped.")
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .padding(10)
                        .foregroundColor(Color(themeManager.currentTheme.color.primaryColor))
                }
            }
            .padding(10)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: Dependency.preview.viewModel.taskChatViewModel())
            .environmentObject(ThemeManager.shared)
    }
}
