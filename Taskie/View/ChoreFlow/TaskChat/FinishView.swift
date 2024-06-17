//
//  FinishView.swift
//  Taskie
//
//  Created by Toan Pham on 6/16/24.
//

import SwiftUI

struct FinishView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.presentationMode) var presentationMode
    
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
                Text("Select up to 4 images of your finished work")
                    .font(.from(uiFont: themeManager.currentTheme.typography.headline2))
                    .multilineTextAlignment(.center)
                HStack {
                    ImageCell()
                    ImageCell()
                }
                
                HStack {
                    ImageCell()
                    ImageCell()
                }
            }
        }
    }
}

struct ImageCell: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var image: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isCamera = false
    @State private var isActionSheetPresented = false
    private var imageCellWidth: CGFloat = 150
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageCellWidth, height: imageCellWidth)
                    .onTapGesture {
                        isActionSheetPresented = true
                    }
            } else {
                ZStack {
                    Rectangle()
                        .fill(Color(themeManager.currentTheme.color.backgroundColor))
                    Image(systemName: "photo.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(Color(themeManager.currentTheme.color.primaryColor))

                }
                .frame(width: imageCellWidth, height: imageCellWidth)
                .onTapGesture {
                    isActionSheetPresented = true
                }
                
            }
        }
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
            ImagePickerView(image: $image, sourceType: isCamera ? .camera : .photoLibrary)
                .ignoresSafeArea()
        }
    }
}

struct FinishView_Previews: PreviewProvider {
    static var previews: some View {
        FinishView()
            .environmentObject(ThemeManager.shared)
    }
}
