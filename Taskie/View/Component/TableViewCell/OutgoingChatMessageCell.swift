//
//  ChatMessageCell.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import UIKit

class OutgoingChatMessageCell: UITableViewCell, Themable {
    private var decoMarkWidthConstraint: NSLayoutConstraint!
    
    private var vStack: UIStackView!
    private var hStack: UIStackView!
    
    private lazy var sendDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .footnote)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bubbleView: UIView = {
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
    
    private lazy var userNameLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var messageLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var decoMark: UIImageView = {
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
        
        vStack = UIStackView.vStack(arrangedSubviews: [messageLabel], alignment: .leading, shouldExpandSubviewWidth: true)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        hStack = UIStackView.hStack(
            arrangedSubviews: [userNameLabel, sendDateLabel],
            alignment: .leading,
            shouldExpandSubviewHeight: true
        )
        hStack.spacing = 10
        hStack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(vStack)
        contentView.addSubview(smileyFace)
        contentView.addSubview(decoMark)
        
        decoMarkWidthConstraint = decoMark.widthAnchor.constraint(equalToConstant: 50)
        
        NSLayoutConstraint.activate([
            smileyFace.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            smileyFace.heightAnchor.constraint(equalToConstant: 40),
            smileyFace.widthAnchor.constraint(equalTo: smileyFace.heightAnchor),
            smileyFace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bubbleView.topAnchor.constraint(equalTo: decoMark.centerYAnchor),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.7),
            bubbleView.trailingAnchor.constraint(equalTo: smileyFace.leadingAnchor, constant: -10),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            decoMarkWidthConstraint,
            decoMark.heightAnchor.constraint(equalTo: decoMark.widthAnchor, multiplier: 1.5),
            decoMark.topAnchor.constraint(equalTo: contentView.topAnchor),
            decoMark.centerXAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            decoMark.centerYAnchor.constraint(equalTo: bubbleView.topAnchor),
            
            vStack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            vStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
            vStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
        ])
    }
    
    func configureCell(with chatMessage: ChatMessage) {
        messageLabel.text = chatMessage.message
        
        switch chatMessage.type {
            case .normal:
                decoMark.isHidden = true
                decoMarkWidthConstraint.constant = 5
            case .request:
                decoMark.isHidden = false
                decoMarkWidthConstraint.constant = 50
                decoMark.image = UIImage(named: "question-mark")
            case .accept:
                decoMark.isHidden = false
                decoMarkWidthConstraint.constant = 50
                decoMark.image = UIImage(named: "exclamation-mark")
        }
        
        checkIsFirstInSequence(chatMessage)
    }
    
    private func checkIsFirstInSequence(_ chatMessage: ChatMessage) {
        if chatMessage.isFirstInSequence {
            if decoMarkWidthConstraint.constant == 5 {
                decoMarkWidthConstraint.constant = 20
            }
            userNameLabel.text = chatMessage.sender.name
            sendDateLabel.text = chatMessage.sendDate
            smileyFace.backgroundColor = .init(hex: chatMessage.sender.profileColor)
            smileyFace.isHidden = false
            
            if hStack.superview == nil {
                vStack.insertArrangedSubview(hStack, at: 0)
            }
        } else {
            smileyFace.isHidden = true
            
            if hStack.superview != nil {
                vStack.removeArrangedSubview(hStack)
                hStack.removeFromSuperview()
            }
        }
    }
    
    func applyTheme(_ theme: PDSTheme) {
        bubbleView.layer.cornerRadius = theme.styling.cornerRadius
        bubbleView.backgroundColor = theme.color.primaryColor
        messageLabel.textColor = theme.color.onPrimary
        userNameLabel.textColor = theme.color.onPrimary
        sendDateLabel.textColor = theme.color.onPrimary
    }
}
