//
//  Checkbox.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 13/02/2022.
//

import Foundation
import UIKit
import RxSwift

class CheckBox: UIButton {
    // Images
    let checkedImage: UIImage = #imageLiteral(resourceName: "ic_check_box")
    let uncheckedImage: UIImage = #imageLiteral(resourceName: "ic_check_box_outline_blank")
    var checkedStateDidChange = PublishSubject<Bool>()
    var callbackChange: ((Bool)->Void)?
    var checked: Bool = false {
        didSet {
            if checked {
                setImage(checkedImage, for: UIControl.State.normal)
            } else {
                setImage(uncheckedImage, for: UIControl.State.normal)
            }
        }
    }
 
    func setState(isChecked: Bool) {
        self.checked = isChecked
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action:#selector(buttonClicked(sender:)), for: UIControl.Event.touchUpInside)
        setImage(uncheckedImage, for: UIControl.State.normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc func buttonClicked(sender: UIButton) {
        if sender == self {
            let newState = !checked
            callbackChange?(newState)
            setState(isChecked: newState)
        }
    }
}
