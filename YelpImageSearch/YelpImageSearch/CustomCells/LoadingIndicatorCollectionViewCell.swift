//
//  LoadingIndicatorCollectionViewCell.swift
//  YelpImageSearch
//
//  Created by Nikhil Patil on 12/22/17.
//  Copyright © 2017 Nikhil Patil . All rights reserved.
//

import UIKit

class LoadingIndicatorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {
        //start activity indicator
        loadingActivityIndicator.startAnimating()
    }
    
}
