//
//  AlertVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit
import SwiftUI

class AlertVC: UIViewController {
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
        view.backgroundColor = ThemeManager.shared.currentTheme.surfaceColor
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "This is a custom alert message."
        label.textColor = ThemeManager.shared.currentTheme.onSurface
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let customButton: PDSPrimaryButton = {
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
        messageLabel.text = alertMessage
        
        view.addSubview(backgroundView)
        view.addSubview(alertView)
        view.addSubview(messageLabel)
        view.addSubview(customButton)
        
        // Apply constraints or frame-based layout
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            alertView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            alertView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            messageLabel.bottomAnchor.constraint(equalTo: customButton.topAnchor, constant: -20),
            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            
            customButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            customButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            customButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setUpActions(){
        customButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
    }
    
    @objc func dismissAlert() {
        self.dismiss(animated: true, completion: nil)
    }
}

struct AlertVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            AlertVC(alertMessage: "This is a custom alert message. This is a long text to test text wrapping.")
        }
    }
}

