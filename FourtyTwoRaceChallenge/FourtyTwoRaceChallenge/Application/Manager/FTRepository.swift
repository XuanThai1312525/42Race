//
//  FTRepository.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 09/02/2022.
//

import Foundation
import UIKit
 
class FTRepository {
    var requestService: FTRequestService!
    var window: UIWindow?
    init() {
        requestService = FTRequestService()
    }
    
    func startup(from window: UIWindow) {
        self.window = window
        window.rootViewController = HomeViewController(viewModel: HomeViewModel(requestor: requestService))
        window.makeKeyAndVisible()

    }
}
