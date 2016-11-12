//
//  RealmHelper.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/12/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper{
    static func persistObject(object: Object, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        DispatchQueue.main.async {
            do {
                try realm.write {
                    realm.add(object, update:true)
                }
                completion(true, object)
            }catch{
                completion(false, error)
            }
        }
    }
    
    static func deleteObject(object: Object, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        DispatchQueue.main.async {
            do {
                try realm.write {
                    realm.delete(object)
                }
                completion(true, object)
            }catch{
                completion(false, error)
            }
        }
    }
    
    static func appendToList(taskToAppend: Task, projectId: String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        DispatchQueue.main.async {
            do {
                try realm.write {
                    if let project = ProjectHelper.projectWithId(projectId: projectId){
                        project.tasks.append(taskToAppend)
                        realm.add(project)
                        completion(true, project)
                    }
                }
            }catch{
                completion(false, error)
            }
        }
    }
    
    static func replaceTaskInList(updatedTask: Task, oldTask: Task, projectId: String,  completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        DispatchQueue.main.async {
            do {
                try realm.write {
                    if let project = ProjectHelper.projectWithId(projectId: projectId){
                        
                        realm.add(project)
                        completion(true, project)
                    }
                }
            }catch{
                completion(false, error)
            }
        }
    }
}
