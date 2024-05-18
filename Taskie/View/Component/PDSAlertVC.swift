//
//  PDSAlertVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit
import SwiftUI

class PDSAlertVC: UIViewController {
    private var buttonAction: (() -> ())? = nil
    
    func configureAlert(
        alertTitle: String,
        alertMessage: String,
        buttonTitle: String,
        buttonAction: @escaping (() -> ())
    ) {
        titleLabel.text = alertTitle
        messageLabel.text = alertMessage
        actionButton.setTitle(buttonTitle, for: .normal)
        self.buttonAction = buttonAction
    }
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let alertView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline2)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpActions()
    }
    
    private func setUpViews() {
        ThemeManager.shared.register(self)
        
        view.addSubview(backgroundView)
        view.addSubview(alertView)
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        view.addSubview(actionButton)
        
        // Apply constraints or frame-based layout
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: alertView.centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -40),
            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            
            actionButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setUpActions(){
        actionButton.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
    }
    
    @objc func handleButtonAction() {
        DispatchQueue.main.async { [weak self] in
            if let buttonAction = self?.buttonAction {
                buttonAction()
            }
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

extension PDSAlertVC: Themable {
    func applyTheme(_ theme: PDSTheme) {
        alertView.backgroundColor = theme.color.surfaceColor
        alertView.layer.cornerRadius = theme.styling.cornerRadius
        messageLabel.textColor = theme.color.onSurface
        titleLabel.textColor = theme.color.errorColor
    }
}

struct AlertVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            PDSAlertVC()
        }
    }
}
