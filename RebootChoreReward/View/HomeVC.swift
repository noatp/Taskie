//
//  HomeViewController.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class HomeVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let choreListVC = UINavigationController(rootViewController: ChoreListVC())
        let profileVC = ProfileVC()
        
        choreListVC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        profileVC.tabBarItem = UITabBarItem(tabBarSystemItem: .contacts, tag: 1)
        self.viewControllers = [choreListVC, profileVC]
        
    }
}

struct HomeVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            HomeVC()
        }
    }
}
