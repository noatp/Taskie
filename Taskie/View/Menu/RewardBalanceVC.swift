//
//  RewardBalanceView.swift
//  Taskie
//
//  Created by Toan Pham on 7/6/24.
//

import SwiftUI
import UIKit
import Combine

class RewardBalanceVC: PDSTitleWrapperVC {
    private var viewModel: RewardBalanceViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let depedencyView: Dependency.View
    
    private lazy var textLabel: PDSLabel = {
        let label = PDSLabel(withText: "Your current reward balance is:", fontScale: .headline2)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var balanceAmountLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline1)
        label.textColor = ThemeManager.shared.currentTheme.color.primaryColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let backBarButton: PDSIconBarButton = {
        let button = PDSIconBarButton(systemName: "chevron.left")
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: RewardBalanceViewModel,
        depedencyView: Dependency.View
    ) {
        self.viewModel = viewModel
        self.depedencyView = depedencyView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        viewModel.$userBalance
            .receive(on: RunLoop.main)
            .sink { [weak self] userBalance in
                self?.balanceAmountLabel.text = "$\(userBalance.formattedToTwoDecimalPlaces())"
            }
            .store(in: &cancellables)
    }
    
    private func setUpViews() {
        setTitle("Reward")
        
        let vStack = UIStackView.vStack(
            arrangedSubviews: [
                textLabel,
                balanceAmountLabel
            ],
            alignment: .center,
            shouldExpandSubviewWidth: false
        )
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setUpActions() {
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

struct RewardBalanceVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            UINavigationController(rootViewController: Dependency.preview.view.rewardBalanceVC())
            
        }
    }
}

extension Dependency.View {
    func rewardBalanceVC() -> RewardBalanceVC {
        return RewardBalanceVC(
            viewModel: viewModel.rewardBalanceViewModel(), depedencyView: self
        )
    }
}
