//
//  PDSIconBarButton.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/7/24.
//

import SwiftUI
import UIKit

enum IconAlignment {
    case leading
    case trailing
}

class PDSIconBarButton: UIButton, Themable {
    init(systemName: String, alignment: IconAlignment = .leading) {
        super.init(frame: .zero)
        setupButton(systemName: systemName, alignment: alignment)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupButton(systemName: String, alignment: IconAlignment) {
        ThemeManager.shared.register(self)
        
        let image = UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate)
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = .scaleAspectFit
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView?.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for the button size
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 44),
            self.heightAnchor.constraint(equalToConstant: 44),
            self.imageView!.widthAnchor.constraint(equalToConstant: 30),
            self.imageView!.heightAnchor.constraint(equalToConstant: 30),
            self.imageView!.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // Adjust content alignment and imageView constraints based on alignment
        switch alignment {
            case .leading:
                self.contentHorizontalAlignment = .left
                self.imageView!.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            case .trailing:
                self.contentHorizontalAlignment = .right
                self.imageView!.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        }
    }
    
    func applyTheme(_ theme: PDSTheme) {
        self.tintColor = theme.color.primaryColor
    }
}

//    init() {
//        super.init(frame: .init(x: 0, y: 0, width: 44, height: 44))
//        configureButton()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private func configureButton() {
//        ThemeManager.shared.register(self)
//    }
//
//
//    override var isHighlighted: Bool {
//        didSet {
//            applyTheme(ThemeManager.shared.currentTheme)
//        }
//    }
//
//    func applyTheme(_ theme: PDSTheme) {
//        var config = UIButton.Configuration.plain()
//        config.baseForegroundColor = theme.color.primaryColor
//        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
//            var outgoing = incoming
//            outgoing.font = theme.typography.button
//            return outgoing
//        }
//        config.imagePadding = .zero
//        config.contentInsets = .zero
//        config.buttonSize = .large
//        self.configuration = config
//    }


struct PDSIconBarButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UIViewPreviewWrapper {
                let button = PDSIconBarButton(systemName: "line.3.horizontal")
                return button
            }
            .fixedSize()
        }
        .previewLayout(.sizeThatFits)
    }
}

