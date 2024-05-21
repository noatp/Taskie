
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
    private var actionButtonType: ChoreForDetailView.actionButtonType = .nothing
    
    private let choreNameLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline2)
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "xmark")
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
    
    private let requestedByLabel: PDSLabel = {
        let label = PDSLabel(withText: "Requested by", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let requestorCard: UserCard = {
        let userCard = UserCard()
        userCard.translatesAutoresizingMaskIntoConstraints = false
        return userCard
    }()
    
    private let acceptedByLabel: PDSLabel = {
        let label = PDSLabel(withText: "Accepted by", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let acceptorCard: UserCard = {
        let userCard = UserCard(reversed: true)
        userCard.translatesAutoresizingMaskIntoConstraints = false
        return userCard
    }()
    
    private let requestDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let finishedDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let actionButton: PDSPrimaryButton = {
        let actionButton = PDSPrimaryButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        return actionButton
    }()
    
    private let choreStatusLabel: PDSLabel = {
        let label = PDSLabel(withText: "Pending", fontScale: .body)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let requestIcon: UIImageView = {
        let icon = UIImage(systemName: "exclamationmark.bubble.fill")
        let iconView = UIImageView(image: icon)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        return iconView
    }()
    
    private let acceptIcon: UIImageView = {
        let icon = UIImage(systemName: "checkmark.bubble.fill")
        let iconView = UIImageView(image: icon)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        return iconView
    }()
    
    private var actionButtonGroup: UIView = .init()
    
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
                
                guard let chore = chore else {
                    self.dismiss(animated: true)
                    return
                }
                
                self.choreNameLabel.text = chore.name
                self.descriptionDetailLabel.text = chore.description
                self.rewardAmountLabel.text = String(format: "$%.2f", chore.rewardAmount)
                self.swipableImageRowVC.imageUrls = chore.imageUrls
                self.requestorCard.configure(
                    withUserName: chore.requestorName,
                    profileColor: .init(hex: chore.requestorProfileColor)
                )
                self.requestDateLabel.text = chore.createdDate
                self.choreStatusLabel.text = chore.choreStatus
                
                if chore.choreStatus == "Finished" {
                    self.acceptedByLabel.text = "Finished by"
                }
                else {
                    self.acceptedByLabel.text = "Accepted by"
                }
                
                if let acceptorName = chore.acceptorName,
                   let acceptorProfileColor = chore.acceptorProfileColor
                {
                    self.acceptedByLabel.isHidden = false
                    self.acceptIcon.isHidden = false
                    self.acceptorCard.isHidden = false
                    self.acceptorCard.configure(withUserName: acceptorName, profileColor: .init(hex: acceptorProfileColor))
                }
                else {
                    self.acceptedByLabel.isHidden = true
                    self.acceptIcon.isHidden = true
                    self.acceptorCard.isHidden = true
                }
                
                if let finishedDate = chore.finishedDate {
                    self.finishedDateLabel.text = finishedDate
                }
                
                self.actionButtonType = chore.actionButtonType
                switch chore.actionButtonType {
                    case .accept:
                        actionButtonGroup.isHidden = false
                        self.actionButton.setTitle("Accept", for: .normal)
                    case .finish:
                        actionButtonGroup.isHidden = false
                        self.actionButton.setTitle("Finished", for: .normal)
                    case .withdraw:
                        actionButtonGroup.isHidden = false
                        self.actionButton.setTitle("Withdraw", for: .normal)
                    case .nothing:
                        actionButtonGroup.isHidden = true
                }
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        ThemeManager.shared.register(self)
        
        guard let swipableImageRow = swipableImageRowVC.view else {
            return
        }
        
        actionButtonGroup = UIStackView.vStack(arrangedSubviews: [
            .createSpacerView(height: 10),
            actionButton,
            .createSpacerView(height: 20)
        ], alignment: .leading, shouldExpandSubviewWidth: true)
        actionButtonGroup.translatesAutoresizingMaskIntoConstraints = false
        
        let choreNameRow = UIView()
        choreNameRow.addSubview(choreNameLabel)
        choreNameRow.addSubview(choreStatusLabel)
        choreNameRow.translatesAutoresizingMaskIntoConstraints = false
        
        let iconAndLabelRow = UIStackView.hStack(
            arrangedSubviews: [
                requestIcon,
                requestedByLabel,
                acceptedByLabel,
                acceptIcon
            ],
            alignment: .center,
            shouldExpandSubviewHeight: true
        )
        iconAndLabelRow.spacing = 10
        iconAndLabelRow.translatesAutoresizingMaskIntoConstraints = false
        
        let userCardRow = UIStackView.hStack(
            arrangedSubviews: [
                requestorCard,
                acceptorCard,
            ],
            alignment: .center,
            shouldExpandSubviewHeight: true
        )
        userCardRow.translatesAutoresizingMaskIntoConstraints = false
        
        let timeRow = UIStackView.hStack(
            arrangedSubviews: [
                requestDateLabel,
                finishedDateLabel
            ],
            alignment: .center,
            shouldExpandSubviewHeight: true
        )
        timeRow.translatesAutoresizingMaskIntoConstraints = false
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            choreNameRow,
            rewardAmountLabel,
            actionButtonGroup,
            .createSeparatorView(),
            descriptionLabel,
            descriptionDetailLabel,
            .createSeparatorView(),
            iconAndLabelRow,
            userCardRow,
            timeRow,
            .createSeparatorView(),
        ], alignment: .leading, shouldExpandSubviewWidth: true)
        vStack.spacing = 10
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
            acceptIcon.heightAnchor.constraint(equalToConstant: 40),
            acceptIcon.widthAnchor.constraint(equalTo: acceptIcon.heightAnchor, multiplier: 1),
            
            requestIcon.heightAnchor.constraint(equalToConstant: 40),
            requestIcon.widthAnchor.constraint(equalTo: requestIcon.heightAnchor, multiplier: 1),

            
            choreNameLabel.leadingAnchor.constraint(equalTo: choreNameRow.leadingAnchor),
            choreNameLabel.centerYAnchor.constraint(equalTo: choreNameRow.centerYAnchor),
            choreNameLabel.heightAnchor.constraint(equalTo: choreNameRow.heightAnchor),
            
            choreStatusLabel.leadingAnchor.constraint(equalTo: choreNameLabel.trailingAnchor, constant: 20),
            choreStatusLabel.trailingAnchor.constraint(equalTo: choreNameRow.trailingAnchor),
            choreStatusLabel.firstBaselineAnchor.constraint(equalTo: choreNameLabel.firstBaselineAnchor),
            
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
        actionButton.addTarget(self, action: #selector(handleActionButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    func applyTheme(_ theme: PDSTheme) {
        view.backgroundColor = theme.color.surfaceColor
        choreNameLabel.textColor = theme.color.primaryColor
        rewardAmountLabel.textColor = theme.color.secondaryColor
        requestIcon.tintColor = theme.color.primaryColor
        acceptIcon.tintColor = theme.color.primaryColor
    }
    
    @objc func handleBack() {
        self.dismiss(animated: true)
    }
    
    @objc func handleActionButton() {
        switch self.actionButtonType {
            case .accept:
                viewModel.acceptSelectedChore()
            case .finish:
                viewModel.finishedSelectedChore()
            case .withdraw:
                viewModel.withdrawSelectedChore()
            case .nothing:
                break
        }
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
                baseVC.present(navVC, animated: true)
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
 
