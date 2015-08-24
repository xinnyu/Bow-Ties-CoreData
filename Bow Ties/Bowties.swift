//
//  Bowties.swift
//  Bow Ties
//
//  Created by 潘新宇 on 15/8/22.
//  Copyright (c) 2015年 Razeware. All rights reserved.
//

import Foundation
import CoreData

class Bowties: NSManagedObject {

    @NSManaged var imageData: NSData
    @NSManaged var isFavorite: NSNumber
    @NSManaged var lastWorn: NSDate
    @NSManaged var name: String
    @NSManaged var rating: NSNumber
    @NSManaged var searchKey: String
    @NSManaged var timesWorn: NSNumber
    @NSManaged var tintColor: AnyObject

}
