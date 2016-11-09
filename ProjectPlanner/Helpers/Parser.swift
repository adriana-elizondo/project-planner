//
//  RealmHelper.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/9/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import RealmSwift

class Parser{
    
    static func parseAndPersistProjectList(jsonArray: [Any]?, completion:@escaping (Results<Project>) -> Void){
        let realm = try! Realm()
        
        guard jsonArray != nil else {return}
        
        for project in jsonArray!{
            if let current = project as? [String : Any],
                let currentProject = Project(JSON: current) {
                try! realm.write {
                    realm.add(currentProject)
                }
            }
        }
        completion(realm.objects(Project.self))
    }
    
    static func projectList() -> Results<Project>{
        let realm = try! Realm()
        return realm.objects(Project.self)
    }
}
