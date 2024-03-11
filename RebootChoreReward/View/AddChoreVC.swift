
//  AddChoreVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/10/24.
//

import SwiftUI
import UIKit

class AddChoreVC: UIViewController {
    private var viewModel: AddChoreViewModel

    init(viewModel: AddChoreViewModel = .init()) {
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
    }

    private func setUpViews() {

    }

    private func setUpActions() {
        
    }
}

struct AddChoreVC_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AddChoreViewModel()
        UIViewControllerPreviewWrapper {
            UINavigationController(rootViewController: AddChoreVC(viewModel: viewModel))
        }
    }
}
 