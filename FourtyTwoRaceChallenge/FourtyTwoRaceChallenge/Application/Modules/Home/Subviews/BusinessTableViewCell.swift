//
//  BusinessTableViewCell.swift
//  FourtyTwoRaceChallenge
//
//  Created by ThaiNguyen on 11/02/2022.
//

import UIKit
import SDWebImage
import FloatRatingView

class BusinessTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var openTimeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingView: FloatRatingView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    static let identifier = "BusinessTableViewCell"
    
    var viewModel: BusinessTableViewModel! {
        didSet {
            reloadData()
        }
    }
    
    func prepareForViewModel(_ viewModel: BusinessTableViewModel) {
        self.viewModel = viewModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func reloadData() {
        avatarImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
        nameLabel.text = viewModel.name
        categoryLabel.text = viewModel.categories
        phoneLabel.text = viewModel.displayPhone
        addressLabel.text = viewModel.address
        priceLabel.text = viewModel.price
        ratingView.rating = Double(viewModel.rating)
        distanceLabel.text = viewModel.distance
    }
    
}
