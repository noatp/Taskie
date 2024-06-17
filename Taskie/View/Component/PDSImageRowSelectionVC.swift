
//  PDSImageRow.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/13/24.
//

import SwiftUI
import UIKit

class PDSImageRowCell: UICollectionViewCell, Themable {
    
    private let imageView = UIImageView()
    private let addImageLabel = PDSLabel(withText: "Add image", fontScale: .button)
    private var activeImageConstraints: [NSLayoutConstraint] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        ThemeManager.shared.register(self)
        
        contentView.addSubview(imageView)
        contentView.addSubview(addImageLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addImageLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(image: UIImage?) {
        NSLayoutConstraint.deactivate(activeImageConstraints)
        
        if let image = image {
            imageView.image = image
            addImageLabel.isHidden = true
            activeImageConstraints = [
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            ]
            NSLayoutConstraint.activate(activeImageConstraints)
        } else {
            imageView.image = UIImage(systemName: "plus")
            addImageLabel.isHidden = false
            activeImageConstraints = [
                imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
                imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),
                imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                
                addImageLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                addImageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
            ]
            NSLayoutConstraint.activate(activeImageConstraints)
        }
    }
    
    func applyTheme(_ theme: PDSTheme) {
        contentView.backgroundColor = theme.color.backgroundColor
        contentView.layer.cornerRadius = theme.styling.cornerRadius
        contentView.layer.borderColor = theme.color.dividerColor.cgColor
        contentView.layer.borderWidth = 1
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.tintColor = theme.color.secondaryColor
        imageView.layer.cornerRadius = theme.styling.cornerRadius
    }
}

class PDSImageSelectionRowVC: UICollectionViewController {
    var images: [UIImage?] = [UIImage(systemName: "plus"), UIImage(systemName: "plus"), UIImage(systemName: "plus"), nil] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var imagePickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    var lastCellShowPicker: Bool
    
    init(lastCellShowPicker: Bool = true) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 100, height: 100) // Initial size, will adjust dynamically
        self.lastCellShowPicker = lastCellShowPicker
        super.init(collectionViewLayout: layout)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PDSImageRowCell.self, forCellWithReuseIdentifier: PDSImageRowCell.className)
        collectionView.backgroundColor = .none
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    func presentImagePicker() {
        guard let delegate = imagePickerDelegate else {
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
}

extension PDSImageSelectionRowVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Determine the content that will define the size of the cell
        if let image = images[indexPath.item] {
            let aspectRatio = image.size.width / image.size.height
            let cellWidth = 100 * aspectRatio
            // Return the size, adding any additional padding or necessary space
            return CGSize(width: cellWidth, height: 100)
        }
        else {
            return CGSize(width: 100, height: 100)
        }
    }
}

extension PDSImageSelectionRowVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PDSImageRowCell.className, for: indexPath) as? PDSImageRowCell else {
            return UICollectionViewCell()
        }
        let image = images[indexPath.item]
        cell.configureCell(image: image)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == images.count - 1 {
            if lastCellShowPicker {
                presentImagePicker()
            }
            //            showLoadingIndicator()
        }
    }
}

struct PDSImageSelectionRowVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            PDSImageSelectionRowVC()
        }
        .frame(width: UIScreen.main.bounds.width, height: 100) // Specify the frame size for the preview
        .previewLayout(.sizeThatFits)
    }
}
