
//  ChoreDetailVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import SwiftUI
import UIKit
import Combine

class ChoreDetailVC: UIViewController, Themable {
    private var viewModel: ChoreDetailViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let swipableImageRowVC = PDSSwipableImageRowVC()
    
    private let choreNameLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline2)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backBarButton: PDSTertiaryButton = {
        let button = PDSTertiaryButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let descriptionLabel: PDSLabel = {
        let label = PDSLabel(withText: "Description", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionDetailLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rewardAmountLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdByLabel: PDSLabel = {
        let label = PDSLabel(withText: "Created by", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let creatorLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(
        viewModel: ChoreDetailViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        addChild(swipableImageRowVC)
        swipableImageRowVC.didMove(toParent: self)
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        viewModel.$choreDetailForView
            .receive(on: RunLoop.main)
            .sink { [weak self] chore in
                self?.choreNameLabel.text = chore.name
                self?.descriptionDetailLabel.text = chore.description
                self?.rewardAmountLabel.text = String(format: "$%.2f", chore.rewardAmount)
                self?.swipableImageRowVC.imageUrls = chore.imageUrls
                self?.creatorLabel.text = chore.creatorName
                self?.createdDateLabel.text = chore.createdDate
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        ThemeManager.shared.register(self)
        
        guard let swipableImageRow = swipableImageRowVC.view else {
            return
        }
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            choreNameLabel,
            .createSpacerView(height: 10),
            rewardAmountLabel,
            .createSpacerView(height: 10),
            createdDateLabel,
            .createSpacerView(height: 20),
            descriptionLabel,
            .createSpacerView(height: 10),
            descriptionDetailLabel,
            .createSpacerView(height: 20),
            createdByLabel,
            .createSpacerView(height: 10),
            creatorLabel
        ], alignment: .leading)
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        swipableImageRow.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(swipableImageRow)
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            swipableImageRow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            swipableImageRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            swipableImageRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            vStack.topAnchor.constraint(equalTo: swipableImageRow.bottomAnchor, constant: 10),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionDetailLabel.widthAnchor.constraint(equalTo: vStack.widthAnchor, multiplier: 1),
            
            swipableImageRow.heightAnchor.constraint(equalToConstant: 300),
            swipableImageRow.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            swipableImageRow.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)
            
        ])
    }

    private func setUpActions() {
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    func applyTheme(_ theme: PDSTheme) {
        view.backgroundColor = theme.color.surfaceColor
        choreNameLabel.textColor = theme.color.primaryColor
        rewardAmountLabel.textColor = theme.color.secondaryColor
    }
    
    @objc func handleBack() {
        self.dismiss(animated: true)
    }
}

struct ChoreDetailVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            let baseVC = UIViewController()
            let choreDetailVC = Dependency.preview.view.choreDetailVC()
            let navVC = UINavigationController(rootViewController: choreDetailVC)
            DispatchQueue.main.async {
                baseVC.present(navVC, animated: true, completion: nil)
            }
            
            return baseVC
        }
    }
}

extension Dependency.View {
    func choreDetailVC() -> ChoreDetailVC {
        return ChoreDetailVC(viewModel: viewModel.choreDetailViewModel())
    }
}
 
