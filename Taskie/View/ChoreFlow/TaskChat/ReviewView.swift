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
                Spacer(minLength: 40)
                Text("Let's review the finished task.")
                    .font(.from(uiFont: themeManager.currentTheme.typography.headline2))
                    .multilineTextAlignment(.center)
                ChatImages(imageUrls: viewModel.chatMessages.last?.imageUrls ?? [])
                    .padding(.horizontal, 20)
                ZStack(alignment: .topLeading) {
                    
                    TextEditor(text: $viewModel.reviewInputText)
                        .font(.from(uiFont: themeManager.currentTheme.typography.body))
                        .frame(height: 150)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(themeManager.currentTheme.color.primaryColor), lineWidth: 1)
                        )
                    
                    if viewModel.reviewInputText.isEmpty {
                        Text("Comment")
                            .font(.from(uiFont: themeManager.currentTheme.typography.body))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                    }
                }
                .padding()
                
                HStack(spacing: 10) {
                    Button(action: {
                        viewModel.approveFinishedChore()
                    }) {
                        HStack {
                            if viewModel.isSendingMessage {
                                ProgressView()
                            }
                            else {
                                Spacer()
                                Text("Approve")
                                    .padding(10)
                                    .font(.from(uiFont: themeManager.currentTheme.typography.button))
                                
                                Spacer()
                            }
                        }
                        .background(Color(themeManager.currentTheme.color.primaryColor))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.denyFinishedChore()
                    }) {
                        HStack {
                            if viewModel.isSendingMessage {
                                ProgressView()
                            }
                            else {
                                Spacer()
                                Text("Deny")
                                    .padding(10)
                                    .font(.from(uiFont: themeManager.currentTheme.typography.button))
                                
                                Spacer()
                            }
                        }
                        .background(Color(themeManager.currentTheme.color.secondaryColor))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
                Spacer()
            }
            .padding(20)
        }
        .onChange(of: viewModel.isSendingMessage) { oldValue, newValue in
            if newValue == false {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel: TaskChatViewModel = Dependency.preview.viewModel.taskChatViewModel()
        ReviewView(viewModel: viewModel)
            .environmentObject(ThemeManager.shared)
    }
}
