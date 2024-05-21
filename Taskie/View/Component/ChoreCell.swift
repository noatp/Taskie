//
//  PDSChoreCell.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/14/24.
//

import UIKit

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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let choreRewardLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
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
        
        NSLayoutConstraint.activate([
            choreImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            choreImageView.heightAnchor.constraint(equalToConstant: 100),
            choreImageView.widthAnchor.constraint(equalTo: choreImageView.heightAnchor, multiplier: 1),
            choreImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            choreImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            choreNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            choreNameLabel.leadingAnchor.constraint(equalTo: choreImageView.trailingAnchor, constant: 10),
            choreNameLabel.trailingAnchor.constraint(equalTo: choreRewardLabel.leadingAnchor, constant: -10),
            
            choreRewardLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            choreRewardLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configureCell(withChore chore: Chore){
        choreNameLabel.text = chore.name
        choreRewardLabel.text = String(format: "$%.2f", chore.rewardAmount)
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
        choreNameLabel.textColor = theme.color.onSurface
        choreRewardLabel.textColor = theme.color.onSurface
        choreImageView.layer.cornerRadius = theme.styling.cornerRadius
    }
}
