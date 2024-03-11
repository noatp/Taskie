
//  AddChoreVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import SwiftUI
import UIKit

class AddChoreVC: UIViewController {
    private var viewModel: AddChoreViewModel
    
    private let titleLabel: PDSLabel = {
        let label = PDSLabel(withText: "Create chore", fontScale: .body, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let choreNameTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Chore name")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let choreDescriptionTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Chore description")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let createChoreButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Create", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: AddChoreViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpActions()
    }

    private func setUpViews() {
        view.backgroundColor = PDSTheme.defaultTheme.color.surfaceColor
        
        let vStack = UIStackView(arrangedSubviews: [
            titleLabel,
            choreNameTextField,
            choreDescriptionTextField,
            createChoreButton
        ])
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.alignment = .center
        vStack.spacing = 20
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setUpActions() {
        
    }
}

struct AddChoreVC_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AddChoreViewModel()
        UIViewControllerPreviewWrapper {
            UINavigationController(rootViewController: AddChoreVC(viewModel: viewModel))
        }
    }
}
 
