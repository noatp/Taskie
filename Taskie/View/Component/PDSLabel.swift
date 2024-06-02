//
//  PDSLabel.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit
import SwiftUI

enum LabelFontScale {
    case headline1
    case headline2
    case body
    case caption
    case button
    case footnote
}

class PDSLabel: UILabel, Themable {
    let labelFontScale: LabelFontScale
    let labelText: String
    let labelTextColor: UIColor?
    
    init(withText labelText: String, fontScale labelFontScale: LabelFontScale, textColor labelTextColor: UIColor? = nil) {
        self.labelFontScale = labelFontScale
        self.labelText = labelText
        self.labelTextColor = labelTextColor
        super.init(frame: .zero)
        configureLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLabel() {
        ThemeManager.shared.register(self)
    }
    
    func applyTheme(_ theme: PDSTheme) {
        text = labelText
        textColor = labelTextColor == nil ? theme.color.onSurface : labelTextColor
        switch labelFontScale {
            case .headline1:
                font = theme.typography.headline1
            case .headline2:
                font = theme.typography.headline2
            case .body:
                font = theme.typography.body
            case .caption:
                font = theme.typography.caption
            case .button:
                font = theme.typography.button
            case .footnote:
                font = theme.typography.footnote
        }
    }
}


struct PDSLabel_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreviewWrapper {
            let label = PDSLabel(withText: "This is a label", fontScale: .body, textColor: .blue)
            
            return label
        }
        .fixedSize()
        .previewLayout(.sizeThatFits)
    }
}

