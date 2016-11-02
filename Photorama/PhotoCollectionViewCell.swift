//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Dilpreet Singh on 26/10/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    func updateWithImage(image: UIImage?) {
        if let imageToDisplay = image {
            spinner.stopAnimating()
            imageView.image = imageToDisplay
        } else {
            spinner.startAnimating()
            imageView.image = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateWithImage(nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        updateWithImage(nil)
    }
}
