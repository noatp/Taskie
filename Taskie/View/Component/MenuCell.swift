//
//  PDSMenuCell.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/7/24.
//

import UIKit

class MenuCell: UITableViewCell, Themable {

    private let optionTitleLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let optionDescriptionLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
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
                
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionDescriptionLabel)
        contentView.addSubview(accessoryImageView)
        
        NSLayoutConstraint.activate([
            optionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            optionTitleLabel.bottomAnchor.constraint(equalTo: optionDescriptionLabel.topAnchor, constant: -10),
            
            optionDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            optionDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 20),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configureCell(withOption optionName: String, optionDescription: String){
        optionTitleLabel.text = optionName
        optionDescriptionLabel.text = optionDescription
    }
    
    func applyTheme(_ theme: PDSTheme) {
        optionTitleLabel.textColor = theme.color.onSurface
        optionDescriptionLabel.textColor = theme.color.onSurface
        accessoryImageView.tintColor = theme.color.secondaryColor
    }
}
