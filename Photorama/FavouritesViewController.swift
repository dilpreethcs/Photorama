//
//  FavouritesViewController.swift
//  Photorama
//
//  Created by Dilpreet Singh on 11/11/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit

class FavouritesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    var allFavouritePhotos: [Photo]? {
        didSet {
            photoDataSource.photos = allFavouritePhotos ?? []
            self.collectionView.reloadSections(IndexSet(integer: 0))
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.allFavouritePhotos = self.store.fetchFavoritePhotos()
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = allFavouritePhotos?[(indexPath as NSIndexPath).row]
        
        if photo?.favourite == true {
            store.fetchImageForPhoto(photo!) { (result) in
                OperationQueue.main.addOperation() {
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? PhotoCollectionViewCell {
                        cell.configureCell(with: photo!, atIndex: indexPath.row)
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: size)
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        collectionView.reloadData()
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhoto" {
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[(selectedIndexPath as NSIndexPath).row]
                let destinationVC = segue.destination as? PhotoInfoViewController
                destinationVC?.photo = photo
                destinationVC?.store = store
            }
        }
    }

    fileprivate let numberOfItemsPerRow = 4

}

extension FavouritesViewController: PhotoCollectionViewCellDelegate {
    func buttonTapped(atIndex: Int) {
        let photoDataSource = self.photoDataSource
        photoDataSource.photos[atIndex].favourite = !photoDataSource.photos[atIndex].favourite
        try! store.coreDataStack.mainQueueContext.save()
        if photoDataSource.photos[atIndex].favourite == true {
            (collectionView.cellForItem(at: IndexPath(item: atIndex, section: 0 )) as! PhotoCollectionViewCell).favouriteButton.backgroundColor = .blue
        } else {
            (collectionView.cellForItem(at: IndexPath(item: atIndex, section: 0 )) as! PhotoCollectionViewCell).favouriteButton.backgroundColor = .gray
        }
    }
}

