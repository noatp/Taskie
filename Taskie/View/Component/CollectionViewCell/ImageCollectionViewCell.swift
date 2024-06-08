//
//  ImageCollectionViewCell.swift
//  Taskie
//
//  Created by Toan Pham on 6/8/24.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    private var task: URLSessionDataTask?
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    func configureCell(imageUrl: String) {
        guard let imageUrl = URL(string: imageUrl) else {
            return
        }
        task = ImageLoader.shared.loadImage(from: imageUrl, completion: { [weak self] image in
            self?.imageView.image = image
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        imageView.image = nil
    }
}

