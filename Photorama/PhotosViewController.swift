//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Dilpreet Singh on 26/10/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var store: PhotoStore!
    let photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        store.fetchRecentPhotos() {
            (PhotosResult) -> Void in
            OperationQueue.main.addOperation() {
                switch PhotosResult {
                case let .success(photos):
                    print("Successfully found \(photos.count) recent photos.")
                    
                    self.photoDataSource.photos = photos
                case let .failure(error):
                    self.photoDataSource.photos.removeAll()
                    print("Error fetching recent photos: \(error)")
                }
            let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
            let allPhotos = try! self.store.fetchMainQueuePhotos(nil, sortDescriptors: [sortByDateTaken])
            OperationQueue.main.addOperation {
                self.photoDataSource.photos = allPhotos
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        try! store.coreDataStack.mainQueueContext.save()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let photo = photoDataSource.photos[(indexPath as NSIndexPath).row]
        
        store.fetchImageForPhoto(photo) { (result) in
            OperationQueue.main.addOperation() {
                let photoIndex = self.photoDataSource.photos.index(of: photo)!
                let photoIndexPath = IndexPath(row: photoIndex, section: 0)
                if let cell = self.collectionView.cellForItem(at: photoIndexPath) as? PhotoCollectionViewCell {
                    cell.configureCell(with: photo, atIndex: photoIndex)
                    cell.delegate = self
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
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

extension PhotosViewController: PhotoCollectionViewCellDelegate {
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
