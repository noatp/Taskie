//
//  PrimaryButton.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class PDSPrimaryButton: UIButton, Themable {
    init() {
        super.init(frame: .zero)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        ThemeManager.shared.register(self)
    }
    
    override var isHighlighted: Bool {
        didSet {
            applyTheme(ThemeManager.shared.currentTheme)
        }
    }
    
    func applyTheme(_ theme: PDSTheme) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = theme.color.primaryColor
        config.baseForegroundColor = theme.color.onPrimary
        config.cornerStyle = .large
        config.title = self.title(for: .normal)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = theme.typography.button
            return outgoing
        }
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
        
        config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
            return self.isHighlighted ? theme.color.darkenPrimaryColor : theme.color.primaryColor
        }
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.4
        
        layer.cornerRadius = theme.styling.cornerRadius
        
        self.configuration = config
    }
}


struct PDSPrimaryButton_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreviewWrapper {
            let button = PDSPrimaryButton()
            button.setTitle("Primary Button", for: .normal)
            return button
        }
        .fixedSize()
        .previewLayout(.sizeThatFits)
    }
}

