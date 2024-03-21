//
//  HomeViewController.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class HomeVC: UITabBarController {
    private let dependencyView: Dependency.View
    
    init(dependencyView: Dependency.View) {
        self.dependencyView = dependencyView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let choreListVC = UINavigationController(rootViewController: dependencyView.choreListVC())
        let profileVC = dependencyView.profileVC()
        
        choreListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        profileVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)
        self.viewControllers = [choreListVC, profileVC]
        
    }
}

struct HomeVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.homeVC()
        }
    }
}

extension Dependency.View {
    func homeVC() -> HomeVC {
        return HomeVC(dependencyView: self)
    }
}
