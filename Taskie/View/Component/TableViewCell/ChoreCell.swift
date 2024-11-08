//
//  PDSChoreCell.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/14/24.
//

import UIKit
import SwiftUI

class ChoreCell: UITableViewCell, Themable {
    private var task: URLSessionDataTask?
    
    private let choreImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let choreNameLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .caption)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let choreRewardLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let choreStatusLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.addSubview(choreImageView)
        contentView.addSubview(choreNameLabel)
        contentView.addSubview(choreRewardLabel)
        contentView.addSubview(choreStatusLabel)
        
        choreNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        choreNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        choreRewardLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        choreRewardLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            choreImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            choreImageView.heightAnchor.constraint(equalToConstant: 100),
            choreImageView.widthAnchor.constraint(equalTo: choreImageView.heightAnchor, multiplier: 1),
            choreImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            choreImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            choreNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            choreNameLabel.leadingAnchor.constraint(equalTo: choreImageView.trailingAnchor, constant: 10),
            choreNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: choreRewardLabel.leadingAnchor, constant: -10),
            
            choreRewardLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            choreRewardLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            choreStatusLabel.leadingAnchor.constraint(equalTo: choreImageView.trailingAnchor, constant: 10),
            choreStatusLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func configureCell(withChore chore: Chore){
        choreNameLabel.text = chore.name
        choreRewardLabel.text = chore.rewardAmount.formattedToTwoDecimalPlaces()
        choreStatusLabel.text = chore.choreStatus
        guard let imageUrl = URL(string: chore.imageUrls.first ?? "") else {
            return
        }
        task = ImageLoader.shared.loadImage(from: imageUrl, completion: { [weak self] image in
            self?.choreImageView.image = image
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        choreImageView.image = nil
    }
    
    func applyTheme(_ theme: PDSTheme) {
        choreNameLabel.textColor = theme.color.onBackground
        choreRewardLabel.textColor = theme.color.onBackground
        choreStatusLabel.textColor = theme.color.onBackground
        choreImageView.layer.cornerRadius = theme.styling.cornerRadius
    }
}

struct ChoreCellPreview: PreviewProvider {
    static var previews: some View {
        // Using UIViewPreviewWrapper to create a view
        UIViewPreviewWrapper {
            // Configure the UITableViewCell here
            let cell = ChoreCell(style: .default, reuseIdentifier: "ChoreCell")
            // Setup dummy data for better preview
            let chore = Chore.empty
            // Replace with actual data structure
            cell.configureCell(withChore: chore)
            return cell
        }
        .previewLayout(.fixed(width: 375, height: 120)) // Adjust size according to the expected cell size
        .padding(10) // Optional padding for better visibility in preview
    }
}
