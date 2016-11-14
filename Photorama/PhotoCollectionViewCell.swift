//
//  PhotoCollectionViewCell.swift
//  Photorama
//
//  Created by Dilpreet Singh on 26/10/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit

@objc protocol PhotoCollectionViewCellDelegate {
    func buttonTapped(atIndex: Int)
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    fileprivate var imageIndex: Int?
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favouriteButton: UIButton!
    
    @IBAction func favouriteButtonDidTap(_ sender: UIButton) {
        delegate?.buttonTapped(atIndex: imageIndex!)
    }
    
    weak var delegate: PhotoCollectionViewCellDelegate?
    
    func configureCell(with photo: Photo, atIndex: Int)  {
        updateWithImage(photo.image)
        imageIndex = atIndex
        if photo.favourite == true {
            favouriteButton.backgroundColor = .blue
        } else {
            favouriteButton.backgroundColor = .gray
        }
    }
    
    fileprivate func updateWithImage(_ image: UIImage?) {
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
