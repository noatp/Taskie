//
//  PrimaryButton.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class PDSPrimaryButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureButton()
    }
    
    private func configureButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .systemBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.title = "Button" // Default title, can be overridden
        config.imagePadding = 10 // Space between image and title if both are used
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

        // Customizing the button for the `.highlighted` state
        config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
            return self.isHighlighted ? UIColor.darkGray : UIColor.systemBlue
        }

        // Custom shadow properties can be added via layer because UIButton.Configuration does not directly support shadows
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.5
        
        self.configuration = config
    }
    
    // If you want to change the appearance when the button is highlighted,
    // you can override the isHighlighted property and update the configuration accordingly.
    override var isHighlighted: Bool {
        didSet {
            configureButton() // Re-apply the configuration to update the background color transformer
        }
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

