//
//  CustomTabBarController.swift
//  facebook-messenger
//
//  Created by Karlos Aguirre on 10/31/18.
//  Copyright © 2018 Karlos Aguirre. All rights reserved.
//

import UIKit

class  CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        let friendsController = FriendsController(collectionViewLayout:layout)
        let recentMessagesNavController = UINavigationController(rootViewController: friendsController)
        recentMessagesNavController.tabBarItem.title = "Recent"
        recentMessagesNavController.tabBarItem.image = UIImage(named: "clock")
        
        viewControllers = [recentMessagesNavController,
                           createDummyNavController(title: "Calls", imageName: "phone"),
                           createDummyNavController(title: "Groups", imageName: "multiple"),
                           createDummyNavController(title: "People", imageName: "man-figure"),
                           createDummyNavController(title: "Settings", imageName: "gear")
                        ]
    }
    
    func createDummyNavController(title:String, imageName:String    ) -> UINavigationController {
        
        let controller = UIViewController()
        let navController = UINavigationController(rootViewController: controller)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        
        return navController
    }
}
