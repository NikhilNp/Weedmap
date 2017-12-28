//
//  BusinessImageCollectionViewCell.swift
//  YelpImageSearch
//
//  Created by Nikhil Patil on 12/22/17.
//  Copyright © 2017 Nikhil Patil . All rights reserved.
//

import UIKit
import SDWebImage

class BusinessImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var businessImageView: UIImageView!
    
    //placeholder displayed while business's image loads or if there is no image found for business
    let placeholderImage = UIImage(named: "weedmaps_abbr_logo")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(imageURLString: String) {
        //load image from passed-in url string
        if let imageURL = URL(string: imageURLString) {
            //load image asynchronously from url
            businessImageView.sd_setImage(with: imageURL, placeholderImage: placeholderImage, options: SDWebImageOptions.retryFailed, completed: nil)
        } else {
            //no image for this business listing, continue to display placeholder for this cell
            businessImageView.image = placeholderImage
        }
    }
}
