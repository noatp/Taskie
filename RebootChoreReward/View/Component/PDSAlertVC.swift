//
//  PDSAlertVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit
import SwiftUI

class PDSAlertVC: UIViewController {
    private let alertMessage: String
    
    init(alertMessage: String) {
        self.alertMessage = alertMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
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
        let label = PDSLabel(withText: "Error", fontScale: .headline2)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dismissButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Dismiss", for: .normal)
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
        
        messageLabel.text = alertMessage
        
        view.addSubview(backgroundView)
        view.addSubview(alertView)
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        view.addSubview(dismissButton)
        
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
            messageLabel.bottomAnchor.constraint(equalTo: dismissButton.topAnchor, constant: -40),
            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            
            dismissButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            dismissButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            dismissButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setUpActions(){
        dismissButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
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
            PDSAlertVC(alertMessage: "This is a custom alert message. This is a long text to test text wrapping.")
        }
    }
}
