//
//  ChatMessageView.swift
//  Taskie
//
//  Created by Toan Pham on 6/12/24.
//

import SwiftUI

struct ChatMessageView: View {
    var message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            if message.isFromCurrentUser {
                Spacer()
                ChatBubbleView(message: message)
                UserImage(profileColor: message.sender.profileColor)
                    .opacity(message.isFirstInSequence ? 1 : 0)
                
            }
            else {
                UserImage(profileColor: message.sender.profileColor)
                    .opacity(message.isFirstInSequence ? 1 : 0)
                ChatBubbleView(message: message)
                Spacer()
            }
        }
        .padding(.top, message.isFirstInSequence ? 20 : 5)
        .padding(message.isFromCurrentUser ? .trailing : .leading, 10)
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

struct ChatMessageView_Previews: PreviewProvider {
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
            isLastInSequence: true)
        ChatMessageView(message: chatMessage)
            .environmentObject(ThemeManager.shared)
    }
}

