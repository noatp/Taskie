//
//  UserCard.swift
//  Taskie
//
//  Created by Toan Pham on 5/18/24.
//

import UIKit
import SwiftUI

class UserCard: UIView {
    init() {
        super.init(frame: .zero)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func setUpViews() {
        addSubview(smileyFace)
        addSubview(userNameLabel)
        
        NSLayoutConstraint.activate([
            smileyFace.leadingAnchor.constraint(equalTo: leadingAnchor),
            smileyFace.topAnchor.constraint(equalTo: topAnchor),
            smileyFace.bottomAnchor.constraint(equalTo: bottomAnchor),
            smileyFace.heightAnchor.constraint(equalToConstant: 40),
            smileyFace.widthAnchor.constraint(equalTo: smileyFace.heightAnchor, multiplier: 1),
            
            userNameLabel.leadingAnchor.constraint(equalTo: smileyFace.trailingAnchor, constant: 10),
            userNameLabel.centerYAnchor.constraint(equalTo: smileyFace.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func configure(withUserName userName: String, profileColor: UIColor) {
        userNameLabel.text = userName
        smileyFace.backgroundColor = profileColor
    }
}

struct UserCard_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreviewWrapper {
            let userCard = UserCard()
            userCard.configure(withUserName: "Some name", profileColor: .green)
            return userCard
        }
        .fixedSize()
        .previewLayout(.sizeThatFits)
    }
}
