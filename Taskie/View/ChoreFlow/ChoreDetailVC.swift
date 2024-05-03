
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
    private var shouldShowActionButton = false
    
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
        let label = PDSLabel(withText: "Requested by", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let requestorLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let acceptedByLabel: PDSLabel = {
        let label = PDSLabel(withText: "Accepted by", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let acceptorLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: PDSPrimaryButton = {
        let actionButton = PDSPrimaryButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        return actionButton
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
        viewModel.$choreDetail
            .receive(on: RunLoop.main)
            .sink { [weak self] chore in
                guard let self = self else {
                    return
                }
                
                self.choreNameLabel.text = chore.name
                self.descriptionDetailLabel.text = chore.description
                self.rewardAmountLabel.text = String(format: "$%.2f", chore.rewardAmount)
                self.swipableImageRowVC.imageUrls = chore.imageUrls
                self.requestorLabel.text = chore.requestorName
                self.createdDateLabel.text = chore.createdDate
                
                if let acceptorName = chore.acceptorName {
                    self.acceptedByLabel.isHidden = false
                    self.acceptorLabel.isHidden = false
                    self.acceptorLabel.text = acceptorName
                    self.actionButton.setTitle("Accept", for: .normal)
                }
                else {
                    self.acceptedByLabel.isHidden = true
                    self.acceptorLabel.isHidden = true
                    self.actionButton.setTitle("Accept", for: .normal)
                }
                                
                switch chore.actionButtonType {
                    case .accept:
                        shouldShowActionButton = true
                        self.actionButton.setTitle("Accept", for: .normal)
                        self.actionButton.addTarget(self, action: #selector(handleAccept), for: .touchUpInside)
                    case .finish:
                        shouldShowActionButton = true
                        self.actionButton.setTitle("Finished", for: .normal)
                    case .withdraw:
                        shouldShowActionButton = true
                        self.actionButton.setTitle("Withdraw", for: .normal)
                    case .nothing:
                        self.shouldShowActionButton = false
                }
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
            rewardAmountLabel,
            .createSpacerView(height: 20),
            actionButton,
            .createSpacerView(height: 20),
            .createSeparatorView(),
            .createSpacerView(height: 10),
            descriptionLabel,
            descriptionDetailLabel,
            .createSpacerView(height: 10),
            .createSeparatorView(),
            .createSpacerView(height: 10),
            createdByLabel,
            requestorLabel,
            createdDateLabel,
            .createSpacerView(height: 10),
            .createSeparatorView(),
            .createSpacerView(height: 10),
            acceptedByLabel,
            acceptorLabel
        ], alignment: .leading, shouldExpandSubviewWidth: true)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        swipableImageRow.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(swipableImageRow)
        scrollView.addSubview(vStack)
        
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            swipableImageRow.topAnchor.constraint(equalTo: scrollView.topAnchor),
            swipableImageRow.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            swipableImageRow.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            swipableImageRow.heightAnchor.constraint(equalToConstant: 300),
            
            vStack.topAnchor.constraint(equalTo: swipableImageRow.bottomAnchor, constant: 10),
            vStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            vStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            vStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
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
    
    @objc func handleAccept() {
        viewModel.acceptSelectedChore()
    }
    
    deinit {
        LogUtil.log("deinit")
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
 
