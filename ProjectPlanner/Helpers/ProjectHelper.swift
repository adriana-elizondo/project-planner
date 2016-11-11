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
    //Load from server
    static func getProjectsWithCompletion(completion : @escaping (_ list : [Project]?) -> Void){
        NetworkHelper.getDataWithDomain(domain: "projects") { (success, result, error) in
            if success{
                DispatchQueue.main.async {
                    parseAndPersistProjectList(jsonArray: result as? [Any]) { (projects) in
                        completion(projects)
                    }
                }
            }
            return
        }
        return completion(nil)
    }
    
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
    
    
    //Post project to server and persist
    static func addProjectWithTitle(title : String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        let project = Project()
        project.title = title
        postToServer(project: project, completion: completion)
    }
    
    static func postToServer(project: Project, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        NetworkHelper.postDataWithDomain(domain: "projects", parameters:"name="+project.title){ (success, result, error) in
            if success {
                if let result = result as? [String : Any], let project = Project.init(JSON: result){
                    project.isSynced = true
                    persistProject(project: project, completion: completion)
                }
            } else {
                project.isSynced = false
                persistProject(project: project, completion: completion)
            }
        }
    }
    
    static func persistProject(project: Project, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        DispatchQueue.main.async {
            let realm = try! Realm()
            do {
                try realm.write {
                    realm.add(project)
                }
                completion(true, nil)
            }catch{
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
    
    static func projectWithId(projectId : String) -> Project?{
        let realm = try! Realm()
        return realm.objects(Project.self).filter("id == '\(projectId)'").first
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
