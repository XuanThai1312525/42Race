//
//  HomeViewController.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 09/02/2022.
//

import UIKit
import RxSwift

class HomeViewController: BaseViewController {

    private let nameTextField = UITextField(frame: .zero)
    private let locationTextField = UITextField(frame: .zero)
    private let typeTextField = UITextField(frame: .zero)
    private let stackView = UIStackView(frame: .zero)
    private let searchButton = UIButton(frame: .zero)
    private let contentTableView = UITableView(frame: .zero, style: .plain)
    var distanceCheckbox: CheckBox!
    var ratingCheckbox: CheckBox!
    private let viewModel: HomeViewModel
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
        
    private func setupView() {
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 8
        view.addSubview(stackView)
        
        let borderColor = UIColor.gray.withAlphaComponent(0.1)
        nameTextField.layer.borderColor = borderColor.cgColor
        locationTextField.layer.borderColor = borderColor.cgColor
        typeTextField.layer.borderColor = borderColor.cgColor

        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.masksToBounds = true
        nameTextField.layer.cornerRadius = 8
        nameTextField.setLeftPaddingPoints(8)
        
        locationTextField.layer.borderWidth = 1.0
        locationTextField.layer.masksToBounds = true
        locationTextField.layer.cornerRadius = 8
        locationTextField.setLeftPaddingPoints(8)
        
        typeTextField.layer.borderWidth = 1.0
        typeTextField.layer.masksToBounds = true
        typeTextField.layer.cornerRadius = 8
        typeTextField.setLeftPaddingPoints(8)
        
        stackView.setLeft(24, relativeToView: view).setRight(-24, relativeToView: view).setTop(50, relativeToView: view)
        nameTextField.setHeight(30)
        searchButton.setTitle("Search", for: .normal)
        stackView.addArrangedSubview(nameTextField)
        stackView.addArrangedSubview(locationTextField)
        stackView.addArrangedSubview(typeTextField)
        stackView.addArrangedSubview(searchButton)
        let sortLabel = UILabel(frame: .zero)
        sortLabel.text = "Sort by:"
        stackView.addArrangedSubview(sortLabel)
        
        let sortStackView = UIStackView(frame: .zero)
        stackView.addArrangedSubview(sortStackView)
        sortStackView.setHeight(35)
        sortStackView.axis = .horizontal
        sortStackView.alignment = .fill
        sortStackView.distribution = .equalCentering
        
        distanceCheckbox = CheckBox(frame: .zero)
        let distanceLabel = UILabel(frame: .zero)
        distanceLabel.text = "Distance"
        let distanceStackView = UIStackView(frame: .zero)
        sortStackView.addArrangedSubview(distanceStackView)
        distanceStackView.spacing = 8.0
        distanceStackView.axis = .horizontal
        distanceStackView.addArrangedSubview(distanceCheckbox)
        distanceStackView.addArrangedSubview(distanceLabel)
    
        ratingCheckbox = CheckBox(frame: .zero)
        let ratingLabel = UILabel(frame: .zero)
        ratingLabel.text = "Rating"
        let ratingStackView = UIStackView(frame: .zero)
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 8.0
        sortStackView.addArrangedSubview(ratingStackView)
        ratingStackView.addArrangedSubview(ratingCheckbox)
        ratingStackView.addArrangedSubview(ratingLabel)
        
        
        view.addSubview(contentTableView)
        contentTableView.setTop(10, relativeToView: stackView, relativeAttribute: .bottom).setBottom(0, relativeToView: view).setLeft(0, relativeToView: view).setRight(0, relativeToView: view)
        contentTableView.register(UINib(nibName: BusinessTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: BusinessTableViewCell.identifier)
        contentTableView.delegate = self
        contentTableView.dataSource = self
        
        view.backgroundColor = .white
        
        searchButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        nameTextField.placeholder = "Enter name!"
        locationTextField.placeholder = "Enter location!"
        typeTextField.placeholder = "Enter cuisine type"
        
        
        #if DEBUG
        nameTextField.text = "delis"
        locationTextField.text = "350 5th Ave, New York, NY 10118"
        typeTextField.text = ""
        #endif
        
        
        distanceCheckbox.callbackChange = {[unowned self] isSelected in
            ratingCheckbox.setState(isChecked: false)
            viewModel.sortType = .distance
        }
        
        ratingCheckbox.callbackChange = {[unowned self] isSelected in
            distanceCheckbox.setState(isChecked: false)
            viewModel.sortType = .rating
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observers()
        setupView()
    }
    
    private func observers() {
        
        viewModel
            .reloadSubject
            .asObservable()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe {[weak self] _ in
                guard let _self = self else {return}
                _self.hideLoading()
                _self.contentTableView.reloadData()
        } onError: { _ in
        }.disposed(by: bag)
        
        searchButton.did(.touchUpInside) {[unowned self] _, _ in
            guard let name = nameTextField.text, let location = locationTextField.text, let type = typeTextField.text else {return}
            showLoading()
            viewModel.getBusiness(name: name, location: location, type: type)
        }
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BusinessTableViewCell.identifier, for: indexPath) as! BusinessTableViewCell
        let viewModel = BusinessTableViewModel(business: viewModel.itemAtIndex(indexPath.row))
        cell.viewModel = viewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}


extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
