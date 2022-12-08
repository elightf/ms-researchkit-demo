//
//  SceneDelegate.swift
//  MSResearchKitDemo
//
//  Created by Eric Lightfoot on 2022-12-06.
//

import CareKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var storeManager: OCKSynchronizedStoreManager {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.storeManager
    }

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions) {

        let feed = CareFeedViewController(storeManager: storeManager)
        feed.title = "Care Feed"
        feed.tabBarItem = UITabBarItem(
            title: "Care Feed",
            image: UIImage(systemName: "heart.fill"),
            tag: 0
        )

//        let insights = InsightsViewController(storeManager: appDelegate.storeManager)
//        insights.title = "Insights"
//        insights.tabBarItem = UITabBarItem(
//            title: "Insights",
//            image: UIImage(systemName: "waveform.path.ecg.rectangle.fill"),
//            tag: 1
//        )

        let root = UITabBarController()
        let feedTab = UINavigationController(rootViewController: feed)
//        let insightsTab = UINavigationController(rootViewController: insights)
        root.setViewControllers([feedTab/*, insightsTab*/], animated: false)

        window = UIWindow(windowScene: scene as! UIWindowScene)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
    }
}

