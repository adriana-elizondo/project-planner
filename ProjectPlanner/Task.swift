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
    var deadline = Deadline()
    dynamic var projectId = 0
    
    override static func primaryKey() -> String? {
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
        deadline <- (map["deadline"])
    }
    
    
}

class Deadline : TransformType{
    typealias Object = Date
    typealias JSON = Double
    
    public func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date.init(timeIntervalSince1970: timeInt)
        }
        return nil
    }
    
    public func transformToJSON(_ value: Date?) -> Double?{
        if let date = value {
            return Double(date.timeIntervalSince1970 * 1000.0)
        }
        return nil
    }
    
}
