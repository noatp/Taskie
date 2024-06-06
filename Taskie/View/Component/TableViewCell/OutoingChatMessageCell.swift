//
//  ChatMessageCell.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Foundation
import UIKit

class OutoingChatMessageCell: UITableViewCell, Themable {
    private var decoMarkWidthConstraint: NSLayoutConstraint!
    
    private let sendDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .footnote)
        label.textAlignment = .right
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
        let label = PDSLabel(withText: "", fontScale: .caption)
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
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
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
        
        decoMarkWidthConstraint = decoMark.widthAnchor.constraint(equalToConstant: 50)
                
        NSLayoutConstraint.activate([
            smileyFace.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            smileyFace.heightAnchor.constraint(equalToConstant: 40),
            smileyFace.widthAnchor.constraint(equalTo: smileyFace.heightAnchor, multiplier: 1),
            smileyFace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bubbleView.topAnchor.constraint(equalTo: decoMark.centerYAnchor, constant: 0),
            bubbleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            bubbleView.trailingAnchor.constraint(equalTo: smileyFace.leadingAnchor, constant: -10),
            
            decoMarkWidthConstraint,
            decoMark.heightAnchor.constraint(equalTo: decoMark.widthAnchor, multiplier: 1.5),
            decoMark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            decoMark.centerXAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            decoMark.centerYAnchor.constraint(equalTo: bubbleView.topAnchor),
            
            sendDateLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            sendDateLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            sendDateLabel.topAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: 5),
            sendDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            userNameLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            userNameLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor,constant: 20),
            userNameLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),

            messageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5),
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
        
        switch chatMessage.type {
            case .normal:
                decoMark.isHidden = true
                decoMarkWidthConstraint.constant = 10
            case .request:
                decoMark.isHidden = false
                decoMarkWidthConstraint.constant = 50
                decoMark.image = UIImage(named: "question-mark")
            case .accept:
                decoMark.isHidden = false
                decoMarkWidthConstraint.constant = 50
                decoMark.image = UIImage(named: "exclamation-mark")
        }
    }

    func applyTheme(_ theme: PDSTheme) {
        bubbleView.layer.cornerRadius = theme.styling.cornerRadius
        bubbleView.backgroundColor = theme.color.primaryColor
        messageLabel.textColor = theme.color.onPrimary
        userNameLabel.textColor = theme.color.onPrimary
    }
}
