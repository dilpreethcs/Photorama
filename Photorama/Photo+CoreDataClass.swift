//
//  Photo+CoreDataClass.swift
//  Photorama
//
//  Created by Dilpreet Singh on 09/11/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    var image: UIImage?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        title = ""
        photoID = ""
        remoteURL = NSURL()
        photoKey = UUID().uuidString
        dateTaken = NSDate()
        timesViewed = 0
        favourite = false
    }
    
    func addTagObject(tag: NSManagedObject) {
        let currentTags = mutableSetValue(forKey: "tags")
        currentTags.add(tag)
    }
    
    func removeTagObject(tag: NSManagedObject) {
        let currentTags = mutableSetValue(forKey: "tags")
        currentTags.remove(tag)
    }
    
}
