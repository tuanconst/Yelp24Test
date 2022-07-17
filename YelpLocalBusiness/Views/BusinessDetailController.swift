//
//  BusinessDetailController.swift
//  YelpLocalPlaces
//
//  Created by Tuan Tran on 7/18/22.
//

import UIKit
import Cosmos
import TagListView

class BusinessDetailController: UIViewController {
    
    @IBOutlet weak var thumnailImageView: UIImageView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var openCloseLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var businessViewModel: BusinessViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let businessViewModel = businessViewModel else { return }
        self.title = businessViewModel.name
        ratingView.rating = businessViewModel.rating
        businessViewModel.fetchThumnail(thumnailImageView.frame.size) { image in
            self.thumnailImageView.image = image
        }
        businessViewModel.fetchBusinessDetail { businessViewModel in
            let categories = businessViewModel.categories
            if !categories.isEmpty {
                categories.forEach({
                    guard let title = $0.title else {
                        return
                    }
                    self.tagListView.addTag(title)
                })
            }
            self.openCloseLabel.textColor = businessViewModel.openNow.displayColor
            self.openCloseLabel.text = businessViewModel.openNow.displayString
            self.addressLabel.text = businessViewModel.displayAddress
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
