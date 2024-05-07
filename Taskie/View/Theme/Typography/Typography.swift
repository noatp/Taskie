//
//  Typography.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit
import SwiftUI

struct PDSTypography {
//    var headline1 = UIFont(name: "Fredoka-Bold", size: 32)
//    var headline2 = UIFont(name: "Fredoka-SemiBold", size: 24)
//    var body = UIFont(name: "Fredoka-Regular", size: 17)
//    var caption = UIFont(name: "Fredoka-Regular", size: 12)
//    var button = UIFont(name: "Fredoka-Medium", size: 17)
    var headline0: UIFont
    var headline1: UIFont
    var headline2: UIFont
    var body: UIFont
    var caption: UIFont
    var button: UIFont
    
    static let defaultTypography = PDSTypography(
        headline0: UIFont(name: "Fredoka-Bold", size: 50) ?? UIFont.systemFont(ofSize: 50, weight: .bold),
        headline1: UIFont(name: "Fredoka-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32, weight: .bold),
        headline2: UIFont(name: "Fredoka-SemiBold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold),
        body: UIFont(name: "Fredoka-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular),
        caption: UIFont(name: "Fredoka-SemiBold", size: 17) ?? UIFont.systemFont(ofSize: 16, weight: .regular),
        button: UIFont(name: "Fredoka-Medium", size: 17) ?? UIFont.systemFont(ofSize: 14, weight: .medium)
    )
}

import UIKit
import SwiftUI

class TypographyPreviewVC: UIViewController {
    private let headline1Label: UILabel = {
        let label = UILabel()
        label.text = "Headline 1"
        label.font = PDSTypography.defaultTypography.headline1
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let headline2Label: UILabel = {
        let label = UILabel()
        label.text = "Headline 2"
        label.font = PDSTypography.defaultTypography.headline2
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.text = "Body"
        label.font = PDSTypography.defaultTypography.body
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "Caption"
        label.font = PDSTypography.defaultTypography.caption
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonLabel: UILabel = {
        let label = UILabel()
        label.text = "Button"
        label.font = PDSTypography.defaultTypography.button
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    private func setUpViews() {
        let stackView = UIStackView(arrangedSubviews: [
            headline1Label,
            headline2Label,
            bodyLabel,
            captionLabel,
            buttonLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // Apply constraints or frame-based layout
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

struct Typography_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            TypographyPreviewVC()
        }
    }
}


