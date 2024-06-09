//
//  OutgoingChatMessageCellWithImage.swift
//  Taskie
//
//  Created by Toan Pham on 6/8/24.
//

import UIKit

class OutgoingChatMessageCellWithImage: UITableViewCell, Themable {
    private var decoMarkHeightConstraint: NSLayoutConstraint!
    private var imageCollectionViewHeightConstraint: NSLayoutConstraint!
    
    private var vStack: UIStackView!
    private var hStack: UIStackView!
    
    private var imageCellHeight: CGFloat = 0
    private let imageCellSpacing: CGFloat = 8
    private var numberOfCellPerRow: CGFloat = 0
    
    private var imageUrls: [String] = [] {
        didSet {
            imageCollectionView.reloadData()
            numberOfCellPerRow = imageUrls.count > 1 ? 2 : 1
            updateImageCollectionViewHeight()
        }
    }
    
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
        let label = PDSLabel(withText: "something", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var messageLabel: PDSLabel = {
        let label = PDSLabel(withText: "something", fontScale: .body)
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
    
    private let imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.className)
        return collectionView
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
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self
        
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
        contentView.addSubview(imageCollectionView)
        
        decoMarkHeightConstraint = decoMark.heightAnchor.constraint(equalToConstant: 50)
//        decoMarkHeightConstraint.priority = .defaultHigh
        imageCollectionViewHeightConstraint = imageCollectionView.heightAnchor.constraint(equalToConstant: 261)
        
        NSLayoutConstraint.activate([
            smileyFace.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            smileyFace.heightAnchor.constraint(equalToConstant: 40),
            smileyFace.widthAnchor.constraint(equalTo: smileyFace.heightAnchor),
            smileyFace.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bubbleView.topAnchor.constraint(equalTo: decoMark.centerYAnchor),
            bubbleView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            bubbleView.trailingAnchor.constraint(equalTo: smileyFace.leadingAnchor, constant: -10),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            decoMarkHeightConstraint,
            decoMark.widthAnchor.constraint(equalTo: decoMark.heightAnchor, multiplier: 0.67),
            decoMark.topAnchor.constraint(equalTo: contentView.topAnchor),
            decoMark.centerXAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            decoMark.centerYAnchor.constraint(equalTo: bubbleView.topAnchor),
            
            vStack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            vStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
            
            imageCollectionView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 20),
            imageCollectionView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -20),
            imageCollectionView.topAnchor.constraint(equalTo: vStack.bottomAnchor, constant: 10),
            imageCollectionView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            imageCollectionViewHeightConstraint
        ])
    }
    
    func configureCell(with chatMessage: ChatMessage) {
        messageLabel.text = chatMessage.message
        imageUrls = chatMessage.imageUrls
        
        switch chatMessage.type {
            case .normal:
                decoMark.isHidden = true
                decoMarkHeightConstraint.constant = 0
            case .request:
                decoMark.isHidden = false
                decoMarkHeightConstraint.constant = 100
                decoMark.image = UIImage(named: "question-mark")
            case .accept:
                decoMark.isHidden = false
                decoMarkHeightConstraint.constant = 100
                decoMark.image = UIImage(named: "exclamation-mark")
        }
        
        checkIsFirstInSequence(chatMessage)
    }
    
    private func checkIsFirstInSequence(_ chatMessage: ChatMessage) {
        if chatMessage.isFirstInSequence {
            if decoMarkHeightConstraint.constant == 5 {
                decoMarkHeightConstraint.constant = 20
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
    
    private func updateImageCollectionViewHeight() {
        layoutIfNeeded()  // Trigger layout to get the correct width
        
        let totalSpacing = (numberOfCellPerRow - 1) * imageCellSpacing
       
        // Calculate total height
        let rows = ceil(CGFloat(imageUrls.count) / numberOfCellPerRow)
        let totalHeight = rows * self.imageCellHeight + (rows - 1) * imageCellSpacing
        
        // Update height constraint
        imageCollectionViewHeightConstraint.constant = totalHeight
        layoutIfNeeded()
    }
    
    func applyTheme(_ theme: PDSTheme) {
        bubbleView.layer.cornerRadius = theme.styling.cornerRadius
        bubbleView.backgroundColor = theme.color.primaryColor
        messageLabel.textColor = theme.color.onPrimary
        userNameLabel.textColor = theme.color.onPrimary
        sendDateLabel.textColor = theme.color.onPrimary
    }
}

extension OutgoingChatMessageCellWithImage: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.className, for: indexPath) as! ImageCollectionViewCell
        cell.configureCell(imageUrl: imageUrls[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing = (numberOfCellPerRow - 1) * imageCellSpacing
        let bubbleViewWidth = UIScreen.main.bounds.width * 0.7
        let itemWidth = (bubbleViewWidth - 40 - totalSpacing) / numberOfCellPerRow
        self.imageCellHeight = itemWidth
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
