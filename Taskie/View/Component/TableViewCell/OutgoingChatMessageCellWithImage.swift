//
//  OutgoingChatMessageCellWithImage.swift
//  Taskie
//
//  Created by Toan Pham on 6/8/24.
//

import UIKit

class OutgoingChatMessageCellWithImage: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // UI Elements
    private let messageLabel = UILabel()
    private let senderLabel = UILabel()
    private let timestampLabel = UILabel()
    private let questionMarkImageView = UIImageView()
    private let smileyFaceImageView = UIImageView()
    private var imageUrls: [String] = []
    private lazy var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    // Constraints
    private var messageTopConstraint: NSLayoutConstraint!
    private var imageCollectionViewTopConstraint: NSLayoutConstraint!
    
    // Initialize UI elements and layout
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Add subviews and setup constraints
        contentView.addSubview(messageLabel)
        contentView.addSubview(senderLabel)
        contentView.addSubview(timestampLabel)
        contentView.addSubview(questionMarkImageView)
        contentView.addSubview(smileyFaceImageView)
        contentView.addSubview(imageCollectionView)
        
        // Set up UI element properties
        questionMarkImageView.image = UIImage(systemName: "questionmark.circle")
        smileyFaceImageView.image = UIImage(systemName: "smiley")
        
        // Example constraints (adjust as needed)
        // Use Auto Layout to position elements correctly
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        senderLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        questionMarkImageView.translatesAutoresizingMaskIntoConstraints = false
        smileyFaceImageView.translatesAutoresizingMaskIntoConstraints = false
        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            smileyFaceImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            smileyFaceImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            smileyFaceImageView.widthAnchor.constraint(equalToConstant: 24),
            smileyFaceImageView.heightAnchor.constraint(equalToConstant: 24),
            
            senderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            senderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            senderLabel.trailingAnchor.constraint(equalTo: smileyFaceImageView.leadingAnchor, constant: -8),
            
            timestampLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            timestampLabel.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 4),
            timestampLabel.trailingAnchor.constraint(equalTo: smileyFaceImageView.leadingAnchor, constant: -8),
            
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            questionMarkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            questionMarkImageView.widthAnchor.constraint(equalToConstant: 24),
            questionMarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            imageCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            imageCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            imageCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        // Dynamic constraints
        messageTopConstraint = messageLabel.topAnchor.constraint(equalTo: timestampLabel.bottomAnchor, constant: 4)
        imageCollectionViewTopConstraint = imageCollectionView.topAnchor.constraint(equalTo: questionMarkImageView.bottomAnchor, constant: 4)
        
        NSLayoutConstraint.activate([
            messageTopConstraint,
            imageCollectionViewTopConstraint
        ])
    }
    
    func configureCell(with chatMessage: ChatMessage) {
        messageLabel.text = chatMessage.message
        senderLabel.text = chatMessage.isFromCurrentUser ? "You" : chatMessage.sender.name
        timestampLabel.text = chatMessage.sendDate
        
        if chatMessage.type == .request {
            questionMarkImageView.isHidden = false
            imageCollectionViewTopConstraint.constant = 4
        } else {
            questionMarkImageView.isHidden = true
            imageCollectionViewTopConstraint.constant = 0
        }
        
        if chatMessage.isFirstInSequence {
            smileyFaceImageView.isHidden = false
            senderLabel.isHidden = false
            timestampLabel.isHidden = false
            messageTopConstraint.constant = 4
        } else {
            smileyFaceImageView.isHidden = true
            senderLabel.isHidden = true
            timestampLabel.isHidden = true
            messageTopConstraint.constant = 8
        }
        
        imageUrls = chatMessage.imageUrls
        imageCollectionView.reloadData()
        
        if imageUrls.isEmpty {
            imageCollectionView.isHidden = true
        } else {
            imageCollectionView.isHidden = false
        }
    }
    
    // UICollectionViewDataSource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        // Configure image view in cell
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // Load image from URL (use a library like SDWebImage)
        // imageView.sd_setImage(with: URL(string: imageUrls[indexPath.item]))
        
        cell.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
        ])
        
        return cell
    }
    
    // UICollectionViewDelegateFlowLayout method
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 8 * 2 + 4 * 2 // 8 is leading/trailing padding, 4 is minimum interitem spacing
        let width = (collectionView.bounds.width - totalSpacing) / 3
        return CGSize(width: width, height: width)
    }
}
