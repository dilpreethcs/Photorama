//
//  ImageStore.swift
//  Photorama
//
//  Created by Dilpreet Singh on 09/11/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit

class ImageStore {
    
    let cache = NSCache<NSString, UIImage>.init()
    
    func imageURLForKey(key: String) -> URL {
        
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
    
    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        
        let imageURL = imageURLForKey(key: key)
        
        if let data = UIImageJPEGRepresentation(image, 0.5) {
            do {
                try data.write(to: imageURL)
            } catch {
            }
        }
    }
    
    func imageForKey(key: String) -> UIImage? {
        if let existingImage = cache.object(forKey: key as NSString) as UIImage! {
            return existingImage
        }
        else {
            let imageURL = imageURLForKey(key: key)
            
            guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path) else {
                return nil
            }
            
            cache.setObject(imageFromDisk, forKey: key as NSString)
            return imageFromDisk
        }
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObject(forKey: key as NSString)
        
        let imageURL = imageURLForKey(key: key)
        do {
            try FileManager.default.removeItem(at: imageURL)
        }
        catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
}
