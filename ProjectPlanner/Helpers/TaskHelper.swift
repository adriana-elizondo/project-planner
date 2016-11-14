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
    static func addTaskWithData(projectId : String, title: String, deadline: Date, completed : Bool, completion : @escaping (_ success : Bool, _ object: Any?) -> Void){
        let parameters = "title=\(title)&deadline=\(String(doubleValueOfDate(date: deadline)))&completed=\(completed.description)"
        let domain = "projects/\(projectId)/tasks"
        let task = Task()
        task.title = title
        task.deadline = deadline
        task.completed = completed
        
        postToServer(task: task, projectId: projectId, domain: domain, parameters: parameters, completion: completion)
    }
    
    static func postToServer(task: Task, projectId: String, domain: String, parameters: String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        NetworkHelper.postDataWithDomain(domain: domain, parameters:parameters){ (success, result, error) in
            if success {
                if let result = result as? [String : Any],
                    let newTask = Task.init(JSON: result){
                    RealmHelper.appendToList(taskToAppend: newTask, projectId: projectId, completion: completion)
                }
            } else {
                DispatchQueue.main.async {
                    task.id = UUID().uuidString
                    RealmHelper.appendToList(taskToAppend: task, projectId: projectId, completion: completion)
                }
            }
        }
    }
    
    //Patch task
    static func patchTask(task : Task, projectId: String, title: String, deadline: String, completed : String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        let parameters = "title=\(title)&deadline=\(deadline)&completed=\(completed)"
        NetworkHelper.patchDataWithDomain(domain: "projects/\(projectId)/tasks/\(task.id)", parameters:parameters){ (success, result, error) in
            var oldTask = task
            if success {
                if let result = result as? [String : Any],
                    let newTask = Task.init(JSON: result){
                    oldTask = newTask
                    RealmHelper.persistObject(object: oldTask, completion: completion)
                }
            } else {
            }

        }
    }
    
    
    
    //Delete task from server and local db
    static func deleteTask(task: Task, projectId: String, completion : @escaping (_ success : Bool, _ error: Any?) -> Void){
        NetworkHelper.deleteDataWithDomain(domain: "projects/"+projectId+"/tasks", parameters: task.id){ (success, result, error) in
            if success {
                RealmHelper.deleteObject(object: task, completion: completion)
            } else {
                RealmHelper.deleteObject(object: task, completion: completion)
            }
        }
    }
    
    static func taskListForProject(project : Project) -> [Task]{
        let tasks = Array(realm.objects(Task.self).filter("projectId == '\(project.id)'"))
        return tasks
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
