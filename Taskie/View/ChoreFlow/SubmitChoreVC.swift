
//  SubmitChoreVC.swift
//  Taskie
//
//  Created by Toan Pham on 5/31/24.
//

import SwiftUI
import UIKit
import Combine

class SubmitChoreVC: PDSTitleWrapperVC {
    private var viewModel: SubmitChoreViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let dependencyView: Dependency.View
    private let imageSelectionRowVC = PDSImageSelectionRowVC()

    private lazy var promptLabel: PDSLabel = {
        let label = PDSLabel(withText: "Take a photo of the finished task.", fontScale: .caption)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.left")
        return button
    }()
    
    init(
        viewModel: SubmitChoreViewModel,
        dependencyView: Dependency.View
    ) {
        self.viewModel = viewModel
        self.dependencyView = dependencyView
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
    }

    private func setUpViews() {
        guard let imageSelectionRow = imageSelectionRowVC.view else {
            return
        }
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            promptLabel,
            .createSpacerView(height: 40),
            imageSelectionRow
        ], alignment: .center)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageSelectionRow.heightAnchor.constraint(equalToConstant: 100),
            imageSelectionRow.leadingAnchor.constraint(equalTo: vStack.leadingAnchor, constant: 20),
            imageSelectionRow.trailingAnchor.constraint(equalTo: vStack.trailingAnchor, constant: -20),
        ])
    }

    private func setUpActions() {
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
}

struct SubmitChoreVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.submitChoreVC()
        }
    }
}
 
extension Dependency.View {
    func submitChoreVC() -> SubmitChoreVC {
        return SubmitChoreVC(
            viewModel: viewModel.submitChoreViewModel(),
            dependencyView: self
        )
    }
}
