//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Dilpreet Singh on 09/11/16.
//  Copyright © 2016 Dilpreet Singh. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var dateTaken: NSDate
    @NSManaged public var photoID: String
    @NSManaged public var photoKey: String
    @NSManaged public var remoteURL: NSURL
    @NSManaged public var title: String
    @NSManaged public var tags: Set<NSManagedObject>
    @NSManaged public var timesViewed: Int64
    @NSManaged public var favourite: Bool

}