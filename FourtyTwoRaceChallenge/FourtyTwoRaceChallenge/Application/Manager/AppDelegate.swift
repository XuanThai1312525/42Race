//
//  AppDelegate.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 09/02/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        AppMainManager.shared.startup(window, launchOptions: launchOptions)
        return true
    }

}

