//
//  BaseViewController.swift
//  FEProblem
//
//  Created by ThaiNguyen on 20/01/2022.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    let bag = DisposeBag()
    private var loadingView: LoadingView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}

extension BaseViewController {
    func showLoading(with text: String? = nil, shouldFullScreen: Bool = true, disableTabbar:Bool = false) {
       
        if loadingView == nil {
            loadingView = LoadingView(frame: .zero)
        }
        
        if loadingView.isDescendant(of: view) {
            view.bringSubviewToFront(loadingView)
            return
        }
        
        self.view.addSubview(loadingView)
        loadingView.setTitle(text ?? "")
        loadingView.setBackGroundColor(UIColor.white.withAlphaComponent(0.9))
        
        ///bangtv for text color
        loadingView.setTextColor(.systemBlue)
        //
        
        if shouldFullScreen {
            loadingView.fullscreen()
        } else {
            loadingView
                .setCenterX(0, relativeToView: self.view)
                .setCenterY(0, relativeToView: self.view)
                .setWidth(50)
                .setHeight(50)
        }
        
        ///disable touch to tabbar when loading if need
        if let items = tabBarController?.tabBar.items, disableTabbar {
                items.forEach { $0.isEnabled = false }
        }
    }
    
    func showLoadingInView(_ view:UIView, with text: String? = nil) {
       
        if loadingView == nil {
            loadingView = LoadingView(frame: .zero)
        }
        
        if loadingView.isDescendant(of: view) {
            view.bringSubviewToFront(loadingView)
            return
        }
        
        view.addSubview(loadingView)
        loadingView.setTitle(text ?? "")
        loadingView.setTextColor(.systemBlue)
        loadingView.setBackGroundColor(.clear)
        loadingView.frame = view.bounds
        loadingView.center = CGPoint(x: view.frame.size.width/2, y: view.frame.size.height/2)
    }
    
    func hideLoading() {
        if loadingView != nil {
            loadingView.removeFromSuperview()
        }
        if let items = tabBarController?.tabBar.items {
                items.forEach { $0.isEnabled = true }
        }
    }
    
    var isLoading: Bool {
        if loadingView == nil {
            return false
        }
        return loadingView.superview != nil
    }
}
