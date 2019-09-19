//
//  Item.swift
//  Notey
//
//  Created by Dionte Silmon on 9/19/19.
//  Copyright © 2019 Dionte Silmon. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var done = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
