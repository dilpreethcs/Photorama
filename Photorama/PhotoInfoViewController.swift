//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Dilpreet Singh on 27/10/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    
    var store: PhotoStore!
    let coreDataStack = CoreDataStack(modelName: "Photorama")

    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImageForPhoto(photo) { (result) in
            switch result {
            case let .success(image):
                OperationQueue.main.addOperation() {
                    self.imageView.image = image
                }
                self.navigationItem.title = "Viewed \(self.photo.timesViewed) times."
                self.photo.timesViewed += 1
                do {
                    try self.store.coreDataStack.saveChanges()
                } catch let error {
                    print("Core Data save failed: \(error)")
                }
            case let .failure(error):
                print("Error in fetching the image for photo: \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowTags" {
            let navController = segue.destination as! UINavigationController
            let tagController = navController.topViewController as! TagsTableViewController
            
            tagController.photoStore = store
            tagController.photo = photo
        }
    }

}
