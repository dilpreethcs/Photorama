//
//  PhotoStore.swift
//  Photorama
//
//  Created by Dilpreet Singh on 26/10/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit
import CoreData

class PhotoStore {
    
    let coreDataStack = CoreDataStack(modelName: "Photorama")
    let imageStore = ImageStore()
    
    enum ImageResult {
        case success(UIImage)
        case failure(Error)
    }
    
    enum PhotoError: Error {
        case imageCreationError
    }
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func fetchFavoritePhotos() -> [Photo]? {
        let favouritePredicate = NSPredicate(format: "favourite == YES")
        let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
        guard let favouritePhotos = try? fetchMainQueuePhotos(favouritePredicate, sortDescriptors: [sortByDateTaken]) else { return nil }
        return favouritePhotos
    }
    
    func fetchRecentPhotos(completion: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.recentPhotosURL()
        let request = URLRequest(url: url as URL)
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in

            var result = self.processRecentPhotosRequest(data: data, error: error as NSError?)
            
            if case let .success(photos) = result {
                let privateQueueContext = self.coreDataStack.privateQueueContext
                privateQueueContext.performAndWait({
                    try! privateQueueContext.obtainPermanentIDs(for: photos)
                })

                let objectIDs = photos.map{ $0.photoID }
                let predicate = NSPredicate(format: "self in %@", argumentArray: [objectIDs])
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate, sortDescriptors: [sortByDateTaken])
                    result = .success(mainQueuePhotos)
                } catch let error {
                    result = .failure(error)
                }
            }
            completion(result)
        })
        task.resume()
    }
    
    func fetchMainQueuePhotos(_ predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos : NSAsynchronousFetchResult<Photo>?
        var fetchRequestError : Error?
        mainQueueContext.performAndWait() {
            do {
                mainQueuePhotos = try mainQueueContext.execute(fetchRequest) as? NSAsynchronousFetchResult<Photo>
            } catch let error {
                fetchRequestError = error
            }
        }
        guard let photos = mainQueuePhotos?.finalResult else {
            throw fetchRequestError!
        }
        return photos
    }
    
    func processRecentPhotosRequest(data: Data?, error: NSError?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return FlickrAPI.photosFromJSONData(jsonData, inContext: self.coreDataStack.privateQueueContext)
    }
    
    func fetchImageForPhoto(_ photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        let photoKey = photo.photoKey
        
        if let image = imageStore.imageForKey(key: photoKey) {
            photo.image = image
            completion(.success(image))
            return
        }
        
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error as NSError?)
            
            if case let .success(image) = result {
                photo.image = image
                self.imageStore.setImage(image: image, forKey: photoKey)
            }
            completion(result)
        })
        task.resume()
        
    }
    
    func processImageRequest(data: Data?, error: NSError?) -> ImageResult {
        guard let imageData = data,
            let image = UIImage(data: imageData) else {
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
    
    func fetchMainQueueTags(_ predicate: NSPredicate? = nil,
                            sortDescriptors: [NSSortDescriptor]? = nil) throws -> [NSManagedObject] {
        
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueueTags: NSAsynchronousFetchResult<Tag>?
        var fetchRequestError: Error?
        mainQueueContext.performAndWait() {
            do {
                mainQueueTags = try mainQueueContext.execute(fetchRequest) as? NSAsynchronousFetchResult<Tag>
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let tags = mainQueueTags?.finalResult else {
            throw fetchRequestError!
        }
        
        return tags
    }
    
}
