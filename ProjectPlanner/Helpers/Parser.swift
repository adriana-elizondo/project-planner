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
    
    static func parseAndPersistProjectList(jsonArray: [Any]?, completion:@escaping ([Project]) -> Void){
        let realm = try! Realm()
        
        guard jsonArray != nil else {return}
        
        for project in jsonArray!{
            if let current = project as? [String : Any],
                let currentProject = Project(JSON: current) {
                try! realm.write {
                    realm.add(currentProject, update: true)
                }
            }
        }
            completion(Array(realm.objects(Project.self)))
        
    }
    
    
}
