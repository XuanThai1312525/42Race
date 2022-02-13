//
//  AppMainManager.swift
//  Earable
//
//  Created by Thai Nguyen on 11/14/19.
//  Copyright © 2019 Earable. All rights reserved.
//

import UIKit

final class AppMainManager {
    static let shared = AppMainManager()
    
    var startingup = true
    var repository = FTRepository()
    
    func startup(_ window: UIWindow?, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let window = window else {return}
        
        // prevent crash when scene invoke delegation functions
        guard startingup else {return}
        startingup = false
        repository.startup(from: window)
    }
}
