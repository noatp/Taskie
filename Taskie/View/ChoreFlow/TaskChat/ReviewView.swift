//
//  ReviewView.swift
//  Taskie
//
//  Created by Toan Pham on 7/3/24.
//

import SwiftUI

struct ReviewView: View {
    @ObservedObject var viewModel: TaskChatViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?
    @State private var isCamera: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .padding(20)
                            .foregroundColor(Color(themeManager.currentTheme.color.primaryColor))
                    }
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Text("Let's review the finished task.")
                    .font(.from(uiFont: themeManager.currentTheme.typography.headline2))
                    .multilineTextAlignment(.center)
                ChatImages(imageUrls: viewModel.chatMessages.last?.imageUrls ?? [])
                    .padding(.horizontal, 20)
                TextEditor(text: $viewModel.chatInputText)
                    .font(.from(uiFont: themeManager.currentTheme.typography.body))
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                    .padding()
                HStack {
                    Button(action: {
                        
                    }) {
                        if viewModel.isSendingMessage {
                            ProgressView()
                                .frame(width: 44, height: 44)
                        }
                        else {
                            Text("Approve")
                        }
                    }
                    
                    Button(action: {
                        
                    }) {
                        if viewModel.isSendingMessage {
                            ProgressView()
                                .frame(width: 44, height: 44)
                        }
                        else {
                            Text("Deny")
                        }
                    }
                }
                
            }
            
        }
        .padding(20)
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel: TaskChatViewModel = Dependency.preview.viewModel.taskChatViewModel()
        ReviewView(viewModel: viewModel)
            .environmentObject(ThemeManager.shared)
    }
}
