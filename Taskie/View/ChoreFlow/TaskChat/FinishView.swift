//
//  FinishView.swift
//  Taskie
//
//  Created by Toan Pham on 6/16/24.
//

import SwiftUI

struct FinishView: View {
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
                Spacer()
                Text("Select up to 4 photos of your finished task")
                    .font(.from(uiFont: themeManager.currentTheme.typography.headline2))
                    .multilineTextAlignment(.center)
                Spacer()
                GeometryReader { geometry in
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            ImageCell(
                                viewModel: viewModel, 
                                image: viewModel.images.count > 0 ? viewModel.images[0] : nil,
                                imageCellWidth: (geometry.size.width - 20) / 2
                            )
                            
                            ImageCell(
                                viewModel: viewModel,
                                image: viewModel.images.count > 1 ? viewModel.images[1] : nil,
                                imageCellWidth: (geometry.size.width - 20) / 2
                            )
                        }
                        
                        HStack(spacing: 20) {
                            ImageCell(
                                viewModel: viewModel,
                                image: viewModel.images.count > 2 ? viewModel.images[2] : nil,
                                imageCellWidth: (geometry.size.width - 20) / 2
                            )
                            ImageCell(
                                viewModel: viewModel,
                                image: viewModel.images.count > 3 ? viewModel.images[3] : nil,
                                imageCellWidth: (geometry.size.width - 20) / 2
                            )
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
                
                
                HStack(spacing: 20) {
                    Button(action: {
                        isImagePickerPresented = true
                        isCamera = false
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Select Photo")
                                .font(.from(uiFont: themeManager.currentTheme.typography.button))
                            Spacer()
                        }
                        .padding(10)
                        .background(Color(themeManager.currentTheme.color.primaryColor))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    })
                    
                    Button(action: {
                        isImagePickerPresented = true
                        isCamera = true
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Take Photo")
                                .font(.from(uiFont: themeManager.currentTheme.typography.button))
                            Spacer()
                        }
                        .padding(10)
                        .background(Color(themeManager.currentTheme.color.secondaryColor))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    })
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
            
                Button(action: {
                    viewModel.finishedSelectedChore()
                }, label: {
                    HStack {
                        Spacer()
                        if viewModel.isSendingMessage {
                            ProgressView()
                        }
                        else {
                            Text("Done")
                                .font(.from(uiFont: themeManager.currentTheme.typography.button))
                        }
                        
                        Spacer()
                    }
                    .padding(10)
                    .background(Color(themeManager.currentTheme.color.primaryColor))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                })
                .padding(.horizontal, 20)
                Spacer()
            }
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let newImage = newValue, newImage != oldValue {
                viewModel.images.append(newImage)
            }
        }
        .onChange(of: viewModel.isSendingMessage) { oldValue, newValue in
            if newValue == false {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(image: $selectedImage, sourceType: isCamera ? .camera : .photoLibrary)
                .ignoresSafeArea()
        }
    }
}

struct ImageCell: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var viewModel: TaskChatViewModel
    var image: UIImage?
    var imageCellWidth: CGFloat
    
    var body: some View {
        ZStack (alignment: .topLeading) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: imageCellWidth, height: imageCellWidth)
                    .clipped()
                    .cornerRadius(10)
                Button(action: {
                    viewModel.removeImage(image: image)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color(themeManager.currentTheme.color.primaryColor))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color(themeManager.currentTheme.color.primaryColor), lineWidth: 2)
                        )
                        .offset(x: -10, y: -10)
                }
            } else {
                Rectangle()
                    .fill(Color(themeManager.currentTheme.color.backgroundColor))
                    .cornerRadius(10)
                    .frame(width: imageCellWidth, height: imageCellWidth)
            }
        }
    }
}

struct FinishView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel: TaskChatViewModel = Dependency.preview.viewModel.taskChatViewModel()
        FinishView(viewModel: viewModel)
            .environmentObject(ThemeManager.shared)
    }
}
