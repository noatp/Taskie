//
//  FamilyMemberCell.swift
//  Taskie
//
//  Created by Toan Pham on 5/20/24.
//

import UIKit

class HouseholdMemberCell: UITableViewCell, Themable {
    
    private let userCard: UserCard = {
        let userCard = UserCard()
        userCard.translatesAutoresizingMaskIntoConstraints = false
        return userCard
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
        
        contentView.addSubview(userCard)
        contentView.addSubview(accessoryImageView)
        
        NSLayoutConstraint.activate([
            userCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            userCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            userCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            userCard.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -10),
            
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 20),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configureCell(for denormUser: DecentrailizedUser){
        userCard.configure(for: denormUser)
    }
    
    func applyTheme(_ theme: PDSTheme) {
        accessoryImageView.tintColor = theme.color.secondaryColor
    }
}

