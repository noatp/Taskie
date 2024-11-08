
//  AddChoreVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import SwiftUI
import UIKit
import Combine

class CreateChoreVC: PDSResizeWithKeyboardVC {
    private var viewModel: CreateChoreViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let imageSelectionRowVC = PDSImageSelectionRowVC()
        
    private let choreNameTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Task name")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let choreDescriptionTextField: PDSTextField = {
        let textField = PDSTextField(withPlaceholder: "Task description")
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let rewardLabel: PDSLabel = {
        let label = PDSLabel(withText: "Reward", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let choreRewardAmountTextField: PDSCurrencyTextField = {
        let textField = PDSCurrencyTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
        
    private let createChoreButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.filled()
        config.title = "Create"
        config.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 30, trailing: 20)
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "xmark")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(viewModel: CreateChoreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        addChild(imageSelectionRowVC)
        imageSelectionRowVC.didMove(toParent: self)
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        viewModel.$images
            .receive(on: RunLoop.main)
            .sink { [weak self] images in
                self?.imageSelectionRowVC.images = images
            }
            .store(in: &cancellables)
        
        viewModel.$createChoreResult
            .receive(on: RunLoop.main)
            .sink { [weak self] createChoreResult in
                guard let createChoreResult = createChoreResult else {
                    return
                }
                switch createChoreResult {
                    case .success():
                        self?.hideLoadingIndicator {
                            self?.dismiss(animated: true)
                        }
                    case .failure(let error):
                        self?.hideLoadingIndicator {
                            self?.showAlert(alertMessage: error.localizedDescription)
                        }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        setTitle("Create Task")
        
        imageSelectionRowVC.imagePickerDelegate = self
        guard let imageSelectionRow = imageSelectionRowVC.view else {
            return
        }
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            imageSelectionRow,
            .createSpacerView(height: 40),
            choreNameTextField,
            .createSpacerView(height: 20),
            choreDescriptionTextField,
            .createSpacerView(height: 40),
            rewardLabel,
            .createSpacerView(height: 10),
            choreRewardAmountTextField,
            .createSpacerView(height: 20)
        ], alignment: .center)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(vStack)
        
        view.addSubview(scrollView)
        view.addSubview(createChoreButton)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            vStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            vStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            vStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            scrollView.bottomAnchor.constraint(equalTo: createChoreButton.topAnchor),
            
            choreNameTextField.widthAnchor.constraint(equalTo: vStack.widthAnchor, multiplier: 1),
            choreDescriptionTextField.widthAnchor.constraint(equalTo: vStack.widthAnchor, multiplier: 1),
            
            imageSelectionRow.heightAnchor.constraint(equalToConstant: 100),
            imageSelectionRow.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            imageSelectionRow.trailingAnchor.constraint(equalTo: vStack.trailingAnchor),
            
            createChoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createChoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createChoreButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setUpActions() {
        createChoreButton.addTarget(self, action: #selector(handleCreateChore), for: .touchUpInside)
        cancelBarButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelBarButton)
    }
    
    @objc func handleCreateChore() {
        showLoadingIndicator()
        viewModel.choreName = choreNameTextField.text
        viewModel.choreDescription = choreDescriptionTextField.text
        viewModel.choreRewardAmount = choreRewardAmountTextField.text
        
        viewModel.createChore()
    }
    
    @objc func handleCancel() {
        dismiss(animated: true)
    }
    
    override func keyboardWillShow(notification: NSNotification) {
        super.keyboardWillShow(notification: notification)
        createChoreButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: -self.getBottomConstraintValue() + 20, trailing: 20)
        self.view.layoutIfNeeded()
    }
    
    override func keyboardWillHide(notification: NSNotification) {
        super.keyboardWillHide(notification: notification)
        createChoreButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 30, trailing: 20)
        self.view.layoutIfNeeded()
    }
    
    override func applyTheme(_ theme: PDSTheme) {
        super.applyTheme(theme)
        choreNameTextField.font = theme.typography.headline2
        rewardLabel.textColor = theme.color.onSurface
        createChoreButton.backgroundColor = theme.color.primaryColor
        createChoreButton.titleLabel?.textColor = theme.color.onPrimary
        createChoreButton.configuration?.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = theme.typography.button
            return outgoing
        }
        createChoreButton.configuration?.background.backgroundColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
            guard let self = self else {
                return theme.color.primaryColor
            }
            return self.createChoreButton.isHighlighted ? theme.color.darkenPrimaryColor : theme.color.primaryColor
        }
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

extension CreateChoreVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            viewModel.add(image: pickedImage)
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Handle cancellation
        picker.dismiss(animated: true)
    }
}

extension CreateChoreVC: UINavigationControllerDelegate {}

struct CreateChoreVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            let baseVC = UIViewController()
            let createChoreVC = Dependency.preview.view.createChoreVC()
            let navVC = UINavigationController(rootViewController: createChoreVC)
            DispatchQueue.main.async {
                baseVC.present(navVC, animated: true)
            }
            
            return baseVC
        }
    }
}

extension Dependency.View {
    func createChoreVC() -> CreateChoreVC {
        return CreateChoreVC(viewModel: viewModel.addChoreViewModel())
    }
}

