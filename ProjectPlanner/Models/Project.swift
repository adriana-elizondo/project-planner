//
//  Project.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/9/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class Project : Object, Mappable{
    dynamic var id = ""
    dynamic var title = ""
    let tasks = List<Task>()

    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    // Mappable
    func mapping(map: Map) {
        id    <- map["id"]
        
        let name = map["name"].currentValue as! String
        self.title = name.removingPercentEncoding!
        
        var tasks: [Task]?
        tasks <- map["tasks"]
        if let tasks = tasks {
            for task in tasks {
                self.tasks.append(task)
            }
        }
    }
}
