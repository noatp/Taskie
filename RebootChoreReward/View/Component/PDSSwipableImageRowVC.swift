//
//  PDSSwipableImageRow.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import SwiftUI
import UIKit

class PDSSwipableImageRowCell: UICollectionViewCell {
    private var task: URLSessionDataTask?

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    private func setUpViews() {
        contentView.backgroundColor = .black
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

class PDSSwipableImageRowVC: UICollectionViewController {
    var imageUrls: [String] = [] {
        didSet {
            if imageUrls.count < 2 {
                pageControl.isHidden = true
            }
            else {
                pageControl.numberOfPages = imageUrls.count
            }
            collectionView.reloadData()
        }
    }
    private let pageControl: UIPageControl = .init()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 300)
        super.init(collectionViewLayout: layout)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(PDSSwipableImageRowCell.self, forCellWithReuseIdentifier: PDSSwipableImageRowCell.className)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
        
        pageControl.numberOfPages = imageUrls.count
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.black
        pageControl.pageIndicatorTintColor = UIColor.gray
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(pageControl)
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

extension PDSSwipableImageRowVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PDSSwipableImageRowCell.className, for: indexPath) as? PDSSwipableImageRowCell else {
            return UICollectionViewCell()
        }
        let imageUrl = imageUrls[indexPath.row]
        cell.configureCell(imageUrl: imageUrl)
        return cell
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        pageControl.currentPage = Int(scrollView.contentOffset.x / pageWidth)
    }
}

struct PDSSwipableImageRowVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            PDSSwipableImageRowVC()
        }
        .frame(width: UIScreen.main.bounds.width, height: 300)
        .previewLayout(.sizeThatFits)
    }
}

