//
//  ChatMessageCell.swift
//  Taskie
//
//  Created by Toan Pham on 6/1/24.
//

import Foundation
import UIKit

class ChatMessageCell: UITableViewCell, Themable {
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var bubbleViewLeadingConstraint: NSLayoutConstraint!
    var bubbleViewTrailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        ThemeManager.shared.register(self)
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(messageLabel)
        bubbleViewLeadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        bubbleViewTrailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        
        NSLayoutConstraint.activate([
//            // Constraints for bubbleView
//            bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
//            bubbleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
//            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),
//            
//            // Constraints for messageLabel
//            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
//            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
//            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
//            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12),
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            bubbleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
        ])
    }
    
    func configureCell(with chatMessage: ChatMessage){
        messageLabel.text = chatMessage.message
        bubbleViewLeadingConstraint.isActive = true
    }
    
    func applyTheme(_ theme: PDSTheme) {
//        optionTitleLabel.textColor = theme.color.onSurface
//        optionDescriptionLabel.textColor = theme.color.onSurface
//        accessoryImageView.tintColor = theme.color.secondaryColor
    }
}
