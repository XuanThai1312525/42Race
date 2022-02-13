//
//  LoadingView.swift
//  Earable
//
//  Created by Admim on 11/24/20.
//  Copyright © 2020 Earable. All rights reserved.
//

import UIKit

class LoadingView: UIView {

//    private var animationContainerView: UIView!
    private var textDescriptionLabel: UILabel!
    private var stackView: UIStackView!
    private let timer = TimerModel()
    private let loadingImageView = UIImageView()
    var containerView : UIView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func setTitle(_ title: String) {
        textDescriptionLabel.text = title
    }
    
    //bangtv set color
    func setTextColor(_ color:UIColor) {
        textDescriptionLabel.textColor = color
    }
    
    func setBackGroundColor(_ color:UIColor) {
        containerView.backgroundColor = color
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.setTop(-10, relativeToView: loadingImageView)
            .setBottom(10, relativeToView: loadingImageView)
            .setCenterX(0, relativeToView: loadingImageView)
            .setRatio(1)
    }
    
    func start() {
        
    }
    
    private func setupUI() {
        loadingImageView.image = UIImage(named: "ic_loading")
        textDescriptionLabel = UILabel(frame: CGRect(x: 0, y: 100, width: 200, height: 50))
        textDescriptionLabel.font = .systemFont(ofSize: 16)
        stackView = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.vertical
        stackView.distribution  = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        stackView.spacing   = 20.0

        stackView.addArrangedSubview(loadingImageView)
        stackView.addArrangedSubview(textDescriptionLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        insertSubview(containerView, belowSubview: stackView)
        backgroundColor = .clear
        
//        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        loadingImageView.setWidth(40).setHeight(40)
//        loadingImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        textDescriptionLabel.setLeft(8, relativeToView: self)
        textDescriptionLabel.setRight(8, relativeToView: self)
        textDescriptionLabel.numberOfLines = 0
        textDescriptionLabel.textAlignment = .center
        
        timer.start(repeatsTimeInterval:.milliseconds(50), queue: .main) {[weak self] in
            guard let _self = self else {return}
            _self.loadingImageView.transform = _self.loadingImageView.transform.rotated(by: CGFloat(-Double.pi / 8))
        }
    }
    
    deinit {
        timer.stop()
    }
}
