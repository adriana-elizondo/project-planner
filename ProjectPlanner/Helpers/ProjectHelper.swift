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
                    RealmHelper.persistObject(object: project, completion: completion)
                }
            } else {
                RealmHelper.persistObject(object: project, completion: completion)
            }
        }
    }
    
    static func deleteProject(project: Project, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        NetworkHelper.deleteDataWithDomain(domain: "projects", parameters:project.id){ (success, result, error) in
            if success {
                RealmHelper.deleteObject(object: project, completion: completion)
            } else {
                RealmHelper.deleteObject(object: project, completion: completion)
            }
        }
        
    }
    
    static func patchProject(project: Project, title: String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        let parameters = "name=\(title)"
        NetworkHelper.patchDataWithDomain(domain: "projects/\(project.id)", parameters:parameters){ (success, result, error) in
            if success {
                if let result = result as? [String : Any], let project = Project.init(JSON: result){
                    RealmHelper.persistObject(object: project, completion: completion)
                }
            } else {
                RealmHelper.persistObject(object: project, completion: completion)
            }
        }
        
    }
}

//Realm
extension ProjectHelper{
    static func projectList() -> [Project]{
        return Array(realm.objects(Project.self))
    }
    
    static func projectWithId(projectId : String) -> Project?{
        return realm.objects(Project.self).filter("id == '\(projectId)'").first
    }
    
    
}

//Formating
extension ProjectHelper{
    static func completedTasksForProject(project: Project) -> [Task]{
        return Array(project.tasks.filter({$0.completed == true}))
    }
    
    static func pendingTasksForProject(project : Project) -> [Task]{
        return Array(project.tasks.filter({$0.completed == false}))
    }
    
    static func sortByName(projects : [Project]) -> [Project]{
        return projects.sorted {$0.title < $1.title}
    }
    
    static func sortByCompleted(projects : [Project]) -> [Project]{
        return projects.sorted {completedTasksForProject(project: $0).count > completedTasksForProject(project: $1).count }
    }
    
    static func sortByPending(projects : [Project]) -> [Project]{
        return projects.sorted {pendingTasksForProject(project: $0).count > pendingTasksForProject(project: $1).count }
    }
}
