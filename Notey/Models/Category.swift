//
//  Category.swift
//  Notey
//
//  Created by Dionte Silmon on 9/19/19.
//  Copyright © 2019 Dionte Silmon. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
}
