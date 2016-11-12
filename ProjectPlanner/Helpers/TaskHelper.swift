//
//  TaskHelper.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/10/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import RealmSwift

class TaskHelper{
    
    //Post project to server and persist
    static func addTaskWithData(projectId : String, title: String, deadline: String, completed : String, completion : @escaping (_ success : Bool, _ object: Any?) -> Void){
        
        NetworkHelper.postDataWithDomain(domain: "projects/"+projectId+"/tasks", parameters:"title="+title+"&deadline="+deadline+"&completed="+completed){ (success, result, error) in
            if success {
                if let result = result as? [String : Any], let task = Task.init(JSON: result){
                    DispatchQueue.main.async {
                        print("JSON \(result)")
                        if let project = ProjectHelper.projectWithId(projectId: projectId){
                            do {
                                try realm.write {
                                    project.tasks.append(task)
                                    realm.add(project)
                                }
                                completion(true, project)
                            }catch{
                                completion(false, error)
                            }
                        }
                    }
                }
            } else {
                completion(false, error)
            }
        }
    }
    
    //Patch task
    static func patchTask(task:Task, projectId: String, title: String, deadline: String, completed : String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        let parameters = "title=\(title)&deadline=\(deadline)&completed=\(completed)"
        NetworkHelper.patchDataWithDomain(domain: "projects/\(projectId)/tasks/\(task.id)", parameters:parameters){ (success, result, error) in
            if success {
                if let result = result as? [String : Any], let task = Task.init(JSON: result){
                    DispatchQueue.main.async {
                        if let project = ProjectHelper.projectWithId(projectId: projectId),
                            let index = project.tasks.index(of: TaskHelper.taskWithId(taskId: task.id)!){
                            do {
                                try realm.write {
                                    var old = project.tasks[index]
                                    old = task
                                    realm.add(old, update: true)
                                }
                                completion(true, project)
                            }catch{
                                completion(false, error)
                            }
                        }
                    }
                }
            } else {
                completion(false, error)
            }
        }

    }
    
    //Delete task from server and local db
    static func deleteTask(task: Task, projectId: String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        NetworkHelper.deleteDataWithDomain(domain: "projects/"+projectId+"/tasks", parameters: task.id){ (success, result, error) in
            if success{
                DispatchQueue.main.async {
                    if let project = ProjectHelper.projectWithId(projectId: projectId),
                        let index = project.tasks.index(of: task){
                        do {
                            try realm.write {
                                project.tasks.remove(objectAtIndex: index)
                                realm.add(project, update: true)
                                realm.delete(task)
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
    
    static func taskListForProject(project : Project) -> [Task]{
        return Array(realm.objects(Task.self).filter("projectId == '\(project.id)'"))
    }
    
    static func taskWithId(taskId: String) -> Task? {
        return realm.object(ofType: Task.self, forPrimaryKey: taskId)
    }
}

//Formatting
extension TaskHelper{
    static func deadlineForTask(task: Task) -> String{
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        
        return dateformatter.string(from: task.deadline)
    }
    
    static func doubleValueOfDate(date: Date) -> Double{
        return Double(date.timeIntervalSince1970 * 1000.0)
    }
    
    static func sortByName(tasks : [Task]) -> [Task]{
        return tasks.sorted {$0.title < $1.title}
    }
    
    static func sortByCompleted(tasks : [Task]) -> [Task]{
        
        return tasks.sorted {Int($0.completed) > Int($1.completed)}
    }
    
    static func sortByPending(tasks : [Task]) -> [Task]{
        return tasks.sorted {Int($0.completed) < Int($1.completed)}
    }
    
    static func sortByDeadline(tasks : [Task]) -> [Task]{
        return tasks.sorted {$0.deadline < $1.deadline}
    }
    
}

extension Int {
    init(_ bool:Bool) {
        self = bool ? 1 : 0
    }
}
