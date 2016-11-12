//
//  UserDefaultsHelper.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/12/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation

class UserDefaultsHelper{
    static func projectsToDelete(){
        UserDefaults.standard.object(forKey: "ProjectsToDelete")
    }
    
    static func projectsToAdd(){
        UserDefaults.standard.object(forKey: "ProjectsToAdd")
    }
    
    static func projectsToUpdate(){
        UserDefaults.standard.object(forKey: "ProjectsToUpdate")
    }
    
    static func tasksToDelete(){
        UserDefaults.standard.object(forKey: "TasksToDelete")
    }
    
    static func tasksToAdd(){
        UserDefaults.standard.object(forKey: "TasksToAdd")
    }
    
    static func tasksToUpdate(){
        UserDefaults.standard.object(forKey: "TasksToUpdate")
    }
}
