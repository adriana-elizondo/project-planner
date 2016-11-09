//
//  Task.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/9/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Task: Object, Mappable{
    dynamic var id = ""
    dynamic var title = ""
    dynamic var completed = false
    dynamic var deadline = Date()
    dynamic var projectId = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        title <- map["name"]
        completed <- map["completed"]
        projectId <- map["project_id"]
        deadline <- (map["deadline"], DateTransform())
    }
    
}
