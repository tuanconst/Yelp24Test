//
//  BusinessSearchResultCell.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/17/22.
//

import UIKit
import Cosmos

class BusinessSearchResultCell: UITableViewCell {
    
    static var Identifier = "BusinessSearchResultCell"
    
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    var businessViewModel: BusinessViewModel? {
        
        didSet {
            guard let businessViewModel = businessViewModel else { return }
            nameLabel.text = businessViewModel.name
            ratingView.rating = businessViewModel.rating
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //thumnailImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
