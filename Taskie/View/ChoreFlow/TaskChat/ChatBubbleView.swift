//
//  ChatBubbleView.swift
//  Taskie
//
//  Created by Toan Pham on 6/12/24.
//

import SwiftUI
import Kingfisher

struct ChatBubbleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var message: ChatMessage
    var body: some View {
        VStack(alignment: .leading) {
            if message.isFirstInSequence {
                HStack {
                    Text(message.sender.name ?? "")
                        .font(.from(uiFont: themeManager.currentTheme.typography.caption))
                        .foregroundStyle(textColor)
                    Text(message.sendDate)
                        .font(.from(uiFont: themeManager.currentTheme.typography.footnote))
                        .foregroundStyle(textColor)
                }
            }
            Text(message.message)
                .font(.from(uiFont: themeManager.currentTheme.typography.body))
                .foregroundStyle(textColor)
            if !message.imageUrls.isEmpty {
                ChatImages(imageUrls: message.imageUrls)
                    .padding(.bottom, 10)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 10.0)
                .fill(backgroundColor)
        )
        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.isFromCurrentUser ? .trailing : .leading)
        .fixedSize(horizontal: false, vertical: true)
        
    }
    
    private var textColor: Color {
        return message.isFromCurrentUser ? Color(themeManager.currentTheme.color.onPrimary) : Color(themeManager.currentTheme.color.onSurface)
    }
    
    private var backgroundColor: Color {
        return message.isFromCurrentUser ? Color(themeManager.currentTheme.color.primaryColor) : Color(themeManager.currentTheme.color.dividerColor)
    }
}

struct ChatImages: View {
    let imageUrls: [String]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    if imageUrls.count == 1 {
                        ChatImage(imageUrl: imageUrls.first!, width: geometry.size.width)
                            .padding(5)
                    }
                    
                    if imageUrls.count >= 2 {
                        ChatImage(imageUrl: imageUrls.first!, width: geometry.size.width / 2)
                        ChatImage(imageUrl: imageUrls[1], width: geometry.size.width / 2)
                    }
                }
                HStack {
                    if imageUrls.count == 3 {
                        ChatImage(imageUrl: imageUrls[2], width: geometry.size.width, height: geometry.size.width / 2)
                    }
                    
                    if imageUrls.count == 4 {
                        ChatImage(imageUrl: imageUrls[2], width: geometry.size.width / 2)
                        ChatImage(imageUrl: imageUrls[3], width: geometry.size.width / 2)
                    }
                }
            }
        }
        .aspectRatio(imageUrls.count > 2 ? 1 : imageUrls.count == 1 ? 1 : 2, contentMode: .fit)
    }
}

struct ChatImage: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var isModalPresented = false
    let imageUrl: String
    let width: Double
    let height: Double?
    
    init(imageUrl: String, width: Double, height: Double? = nil) {
        self.imageUrl = imageUrl
        self.width = width
        self.height = height
    }
    
    var body: some View {
        KFImage(URL(string: imageUrl))
            .placeholder {
                ProgressView()
            }
            .resizable()
            .fade(duration: 0.25)
            .scaledToFill()
            .frame(width: width - 5, height: height ?? width)
            .clipped()
            .cornerRadius(10)
            .onTapGesture {
                isModalPresented = true
            }
            .sheet(isPresented: $isModalPresented) {
                imageModalView
            }
    }
    
    private var imageModalView: some View {
        ZStack {
            VStack {
                HStack {
                    Button(action: {
                        isModalPresented = false
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
            KFImage(URL(string: imageUrl))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFit()
        }
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        let chatMessage = ChatMessage(
            id: "some id",
            message: "This is a message",
            sender: .init(
                id: "some id",
                name: "Bert",
                profileColor: "#00FF00"
            ),
            isFromCurrentUser: true,
            imageUrls: [],
            sendDate: "5 seconds ago",
            type: .normal,
            isFirstInSequence: true,
            isLastInSequence: true
        )
        
        let chatMessageWithImages = ChatMessage(
            id: "some id",
            message: "This is a message",
            sender: .init(
                id: "some id",
                name: "Bert",
                profileColor: "#00FF00"
            ),
            isFromCurrentUser: true,
            imageUrls: [
                "https://firebasestorage.googleapis.com:443/v0/b/taskit-8c240.appspot.com/o/images%2F345B78C4-6176-43C8-9E8E-8EB96DB0ECA8.jpg?alt=media&token=fcf67158-1415-490e-a6f4-443a1034343b",
                "https://firebasestorage.googleapis.com:443/v0/b/taskit-8c240.appspot.com/o/images%2FA5C70E2F-18B4-4201-A243-596CB646BD70.jpg?alt=media&token=3307417c-8d79-4b35-ae9d-9318ad210426",
                "https://firebasestorage.googleapis.com:443/v0/b/taskit-8c240.appspot.com/o/images%2F31BABF09-3F36-4C86-9E7D-E2CD227DF1E8.jpg?alt=media&token=31252ff2-ca33-4bf0-8a7d-6c196ece7419",
                "https://firebasestorage.googleapis.com:443/v0/b/taskit-8c240.appspot.com/o/images%2F72492DDC-8B1D-433B-9BFF-72392C3B6EE7.jpg?alt=media&token=d2d38791-64b9-45e6-87ca-b5287ec5b7c3"
            ],
            sendDate: "5 seconds ago",
            type: .normal,
            isFirstInSequence: true,
            isLastInSequence: true
        )
        VStack {
            ChatBubbleView(message: chatMessage)
                .previewLayout(.sizeThatFits)
            
            ChatBubbleView(message: chatMessageWithImages)
                .previewLayout(.sizeThatFits)
        }
        .environmentObject(ThemeManager.shared)
    }
}



