//
//  PickProfileColorVC.swift
//  Taskie
//
//  Created by Toan Pham on 5/9/24.
//

import UIKit
import SwiftUI
import Combine

class PickProfileColorVC: PDSTitleWrapperVC {
    private let viewModel: PickProfileColorViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var emailPrompt: PDSLabel = {
        let label = PDSLabel(withText: "Choose a color for your profile.", fontScale: .headline2)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var smileyFace: UIImageView = {
        let image = UIImage(named: "smileyFace")
        let imageView = UIImageView(image: image)
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var pickColorButton: PDSSecondaryButton = {
        let button = PDSSecondaryButton()
        button.setTitle("Pick color", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var continueButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Continue", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: PickProfileColorViewModel) {
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
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.$colorCheckResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] colorCheckResult in
                guard let self = self,
                      let colorCheckResult = colorCheckResult
                else {
                    return
                }
                
                switch colorCheckResult {
                    case .success():
                        break
                    case .failure(let error):
                        showAlert(alertMessage: error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        setTitle("Sign up")
        
        let nameTextFieldTopSpace = UIView.createSpacerView()
        let nameTextFieldBottomSpace = UIView.createSpacerView()
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            emailPrompt,
            nameTextFieldTopSpace,
            smileyFace,
            .createSpacerView(height: 20),
            pickColorButton,
            nameTextFieldBottomSpace,
            continueButton,
        ], alignment: .center)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            nameTextFieldTopSpace.heightAnchor.constraint(equalTo: nameTextFieldBottomSpace.heightAnchor),
            
            smileyFace.heightAnchor.constraint(equalTo: smileyFace.widthAnchor, multiplier: 1),
            smileyFace.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
    }
    
    private func setUpActions() {
        pickColorButton.addTarget(self, action: #selector(presentColorPicker), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
    }
    
    @objc func handleContinue() {
        viewModel.updateUserWithProfileColor(smileyFace.backgroundColor?.hexString)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func presentColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension PickProfileColorVC: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        // Use the selected color, e.g., apply it to a view background
        smileyFace.backgroundColor = selectedColor
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        // Handle the color picker closing if needed
    }
}

struct PickProfileColorVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.pickProfileColorVC()
        }
    }
}

extension Dependency.View {
    func pickProfileColorVC() -> PickProfileColorVC {
        return PickProfileColorVC(
            viewModel: viewModel.pickProfileColorViewModel()
        )
    }
}


