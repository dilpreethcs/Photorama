//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Dilpreet Singh on 26/10/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import Foundation
import CoreData

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

enum FlickrError: Error {
    case invalidJSONData
}

struct FlickrAPI {
    
    // MARK: Base URL
    fileprivate static let baseURLString = "https://api.flickr.com/services/rest"
    
    // MARK: Flickr API Key
    fileprivate static let APIKey = "a6d819499131071f158fd740860a5a88"
    
    // MARK: Date Formatter
    fileprivate static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    // MARK: Methods to create URL
    
    fileprivate static func flickrURL(method: Method, parameters: [String : String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method" : method.rawValue,
            "format" : "json",
            "nojsoncallback" : "1",
            "api_key" : APIKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
    
    static func recentPhotosURL() -> URL {
        return flickrURL(method: .RecentPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    
    // MARK: Fetch Photo
    
    static func photosFromJSONData(_ data: Data, inContext context : NSManagedObjectContext) -> PhotosResult {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let jsonDictionary = jsonObject as? [AnyHashable: Any],
                let photos = jsonDictionary["photos"] as? [String : AnyObject],
                let photosArray = photos["photo"] as? [[String : AnyObject]] else {
                    return .failure(FlickrError.invalidJSONData)
            }
            
            var finalPhotos = [Photo]()
            
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(photoJSON, inContext: context) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                return .failure(FlickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch {
            return .failure(error)
        }
    }
    
    static func photoFromJSONObject(_ json: [String : AnyObject ], inContext context : NSManagedObjectContext) -> Photo? {
        guard let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = NSURL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                return nil
        }
        var fetchedPhotos = NSAsynchronousFetchResult<Photo>.init()
        
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "photoID == \(photoID)")
        fetchRequest.predicate = predicate
        
        context.performAndWait() {
            fetchedPhotos = try! context.execute(fetchRequest) as! NSAsynchronousFetchResult<Photo>
        }
        
        if (fetchedPhotos.finalResult?.count ?? 0) > 0 {
            return fetchedPhotos.finalResult?.first
        }
        
        var photo: Photo!
        context.performAndWait {
            photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
            photo.title = title
            photo.photoID = photoID
            photo.remoteURL = url
            photo.dateTaken = dateTaken as NSDate
            photo.timesViewed = 0
        }
        return photo
    }
}
