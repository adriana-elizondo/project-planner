//
//  ProjectHelper.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/9/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class ProjectHelper {
    //Load from server or local database
    static func getProjectsWithCompletion(loadLocal : Bool, completion : @escaping (_ list : [Project]) -> Void){
        let persistedList = ProjectHelper.projectList()
        guard loadLocal, persistedList.count > 0 else {
            NetworkHelper.getDataWithDomain(domain: "projects") { (success, result, error) in
                if success{
                    DispatchQueue.main.async {
                        Parser.parseAndPersistProjectList(jsonArray: result as? [Any], completion: { (projects) in
                            completion(projects)
                        })
                    }
                }
            }
            return
        }
        return completion(persistedList)
    }
    
    //Post project to server and persist
    static func addProjectWithTitle(title : String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        let realm = try! Realm()
        
        
        NetworkHelper.postDataWithDomain(domain: "projects", parameters:"name="+title){ (success, result, error) in
            if success {
                if let result = result as? [String : Any], let project = Project.init(JSON: result){
                    DispatchQueue.main.async {
                        do {
                            try realm.write {
                                realm.add(project)
                            }
                            completion(success, nil)
                        }catch{
                            completion(false, error)
                        }
                    }
                    
                }
                
            } else {
                completion(false, error)
            }
        }
    }
    
    //Delete project from server and local db
    static func deleteProject(project: Project, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        let realm = try! Realm()
        
        NetworkHelper.deleteDataWithDomain(domain: "projects", parameters:project.id){ (success, result, error) in
            if success {
                DispatchQueue.main.async {
                    do {
                        try realm.write {
                            realm.delete(project)
                        }
                        completion(success, nil)
                    }catch{
                        completion(false, error)
                    }
                }
            } else {
                completion(false, error)
            }
        }
        
    }
    
    static func projectList() -> [Project]{
        let realm = try! Realm()
        return Array(realm.objects(Project.self))
        
    }
}

extension ProjectHelper{
    static func completedTasksForProject(project: Project) -> [Task]{
        return Array(project.tasks.filter({$0.completed == true}))
    }
    
    static func pendingTasksForProject(project : Project) -> [Task]{
        return Array(project.tasks.filter({$0.completed == false}))
    }
}
