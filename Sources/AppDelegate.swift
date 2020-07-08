//
//  AppDelegate.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()
        let postVC = RepositoryListViewController()
        let nav = UINavigationController(rootViewController: postVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
        configureUI()
        return true
    }
    private func configureUI() {
        UIView.appearance().overrideUserInterfaceStyle = .dark
    }
}
