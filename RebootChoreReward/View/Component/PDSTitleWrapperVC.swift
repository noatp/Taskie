//
//  PDSTitleWrapperVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/7/24.
//

import UIKit
import SwiftUI

class PDSTitleWrapperVC: UIViewController, Themable {
    private let vcTitleLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var titleBottomAnchor: NSLayoutYAxisAnchor {
        return vcTitleLabel.bottomAnchor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    private func setUpViews() {
        ThemeManager.shared.register(self)
        
        view.addSubview(vcTitleLabel)
        
        NSLayoutConstraint.activate([
            vcTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            vcTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    func setTitle(_ title: String){
        vcTitleLabel.text = title
    }
    
    func applyTheme(_ theme: PDSTheme) {
        vcTitleLabel.textColor = theme.color.primaryColor
    }
}

struct PDSTitleWrapperVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            let viewController = PDSTitleWrapperVC()
            viewController.setTitle("Test")
            return viewController
        }
    }
}
