
//  ChoreDetailVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import SwiftUI
import UIKit
import Combine

class ChoreDetailVC: UIViewController {
    private var viewModel: ChoreDetailViewModel
    private var cancellables: Set<AnyCancellable> = []

    private let titleLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline1, textColor: PDSTheme.defaultTheme.color.secondaryColor)
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
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        viewModel.$chore
            .receive(on: RunLoop.main)
            .sink { [weak self] chore in
                self?.titleLabel.text = chore.name
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        view.backgroundColor = PDSTheme.defaultTheme.color.surfaceColor
        
        let vStack = UIStackView(arrangedSubviews: [
            titleLabel
        ])
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.alignment = .center
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            vStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setUpActions() {
        
    }
}

struct ChoreDetailVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.choreDetailVC()
        }
    }
}

extension Dependency.View {
    func choreDetailVC() -> ChoreDetailVC {
        return ChoreDetailVC(viewModel: viewModel.choreDetailViewModel())
    }
}
 
