//
//  ChatMessageCell.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Foundation
import UIKit

class ChatMessageCell: UITableViewCell, Themable {
    private var incomingBackgroundColor: UIColor = .clear
    private var outgoingBackgroundColor: UIColor = .clear
    private var incomingTextColor: UIColor = .clear
    private var outgoingTextColor: UIColor = .clear
    
    private let sendDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var smileyFace: UIImageView = {
        let image = UIImage(named: "smileyFace")
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let userNameLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let decoMark: UIImageView = {
        let image = UIImage(named: "exclamation-mark")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var bubbleViewLeadingConstraint: NSLayoutConstraint!
    var bubbleViewTrailingConstraint: NSLayoutConstraint!
    var senderCardLeadingConstraint: NSLayoutConstraint!
    var senderCardTrailingConstraint: NSLayoutConstraint!
    var decoMarkCenterXConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        ThemeManager.shared.register(self)
        selectionStyle = .none
        
        contentView.addSubview(sendDateLabel)
        contentView.addSubview(bubbleView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(smileyFace)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(decoMark)
        
        bubbleViewLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: smileyFace.trailingAnchor, constant: 10)
        bubbleViewTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: smileyFace.leadingAnchor, constant: -10)
        
        senderCardLeadingConstraint = smileyFace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10)
        senderCardTrailingConstraint = smileyFace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
                
        NSLayoutConstraint.activate([
            decoMark.widthAnchor.constraint(equalToConstant: 50),
            decoMark.heightAnchor.constraint(equalTo: decoMark.widthAnchor, multiplier: 1.5),
            decoMark.topAnchor.constraint(equalTo: contentView.topAnchor),
            
            smileyFace.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            smileyFace.heightAnchor.constraint(equalToConstant: 40),
            smileyFace.widthAnchor.constraint(equalTo: smileyFace.heightAnchor, multiplier: 1),
            
            bubbleView.topAnchor.constraint(equalTo: decoMark.centerYAnchor, constant: 0),
            bubbleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            
            sendDateLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            sendDateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            sendDateLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 5),
            sendDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            userNameLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            userNameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor,constant: 20),
            userNameLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),

            messageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
        ])
    }
    
    func configureCell(with chatMessage: ChatMessage){
        messageLabel.text = chatMessage.message
        smileyFace.backgroundColor = .init(hex: chatMessage.sender.profileColor)
        userNameLabel.text = chatMessage.sender.name
        sendDateLabel.text = chatMessage.sendDate
        
        if chatMessage.isFromCurrentUser {
            decoMarkCenterXConstraint = decoMark.centerXAnchor.constraint(equalTo: bubbleView.leadingAnchor)
            decoMarkCenterXConstraint.isActive = true
            bubbleViewTrailingConstraint.isActive = true
            senderCardTrailingConstraint.isActive = true
            bubbleView.backgroundColor = outgoingBackgroundColor
            messageLabel.textColor = outgoingTextColor
            userNameLabel.textColor = outgoingTextColor
            userNameLabel.textAlignment = .right
            sendDateLabel.textAlignment = .right
        }
        else {
            decoMarkCenterXConstraint = decoMark.centerXAnchor.constraint(equalTo: bubbleView.trailingAnchor)
            decoMarkCenterXConstraint.isActive = true
            bubbleViewLeadingConstraint.isActive = true
            senderCardLeadingConstraint.isActive = true
            bubbleView.backgroundColor = incomingBackgroundColor
            messageLabel.textColor = incomingTextColor
            userNameLabel.textColor = incomingTextColor
        }
    }
    
    func applyTheme(_ theme: PDSTheme) {
        bubbleView.layer.cornerRadius = theme.styling.cornerRadius
        incomingBackgroundColor = theme.color.dividerColor
        outgoingBackgroundColor = theme.color.primaryColor
        incomingTextColor = theme.color.onSurface
        outgoingTextColor = theme.color.onPrimary
    }
}
