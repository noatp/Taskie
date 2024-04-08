//
//  PDSTertiaryButton.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/7/24.
//

import SwiftUI
import UIKit

class PDSTertiaryButton: UIButton, Themable {
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
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = theme.color.primaryColor
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = theme.typography.button
            return outgoing
        }
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
        self.configuration = config
    }
}


struct PDSTertiaryButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UIViewPreviewWrapper {
                let button = PDSTertiaryButton()
                button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
                return button
            }
            .fixedSize()
            
//            UIViewPreviewWrapper {
//                let button = PDSTertiaryButton()
//                button.setTitle("Back", for: .normal)
//                return button
//            }
//            .fixedSize()
//            
//            UIViewPreviewWrapper {
//                let button = PDSTertiaryButton()
//                button.setTitle("Back", for: .normal)
//                button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
//                return button
//            }
//            .fixedSize()
        }
        .previewLayout(.sizeThatFits)
    }
}

