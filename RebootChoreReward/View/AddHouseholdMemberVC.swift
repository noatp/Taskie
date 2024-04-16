
//  AddHouseholdMemberVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 4/14/24.
//

import SwiftUI
import UIKit
import Combine

class AddHouseholdMemberVC: PDSTitleWrapperVC {
    private var viewModel: AddHouseholdMemberViewModel
    private var cancellables: Set<AnyCancellable> = []

    private let inviteCodeLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(viewModel: AddHouseholdMemberViewModel) {
        self.viewModel = viewModel
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
        viewModel.$inviteCode
            .receive(on: RunLoop.main)
            .sink { [weak self] inviteCode in
                self?.inviteCodeLabel.text = inviteCode
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        setTitle("Add member")
        
        view.addSubview(inviteCodeLabel)
        
        NSLayoutConstraint.activate([
            inviteCodeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            inviteCodeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setUpActions() {
        
    }
    
    override func applyTheme(_ theme: PDSTheme) {
        super.applyTheme(theme)
        view.backgroundColor = theme.color.surfaceColor
    }
    
    deinit {
        LogUtil.log("deinit")
    }
}

struct AddHouseholdMemberVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            let baseVC = UIViewController()
            let addHouseholdMemberVC = Dependency.preview.view.addHouseholdMemberVC()
            let navVC = UINavigationController(rootViewController: addHouseholdMemberVC)
            DispatchQueue.main.async {
                baseVC.present(navVC, animated: true, completion: nil)
            }
            
            return baseVC
        }
    }
}

extension Dependency.View {
    func addHouseholdMemberVC() -> AddHouseholdMemberVC {
        return AddHouseholdMemberVC(viewModel: viewModel.addHouseholdMemberViewModel())
    }
}
