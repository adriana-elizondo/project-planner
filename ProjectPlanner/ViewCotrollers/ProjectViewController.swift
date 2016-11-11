//
//  ProjectViewController.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/10/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class ProjectViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var noTasksLabel: UILabel!
    
    var taskList = [Task](){
        didSet{
            guard noTasksLabel != nil, tableView != nil else {
                return
            }
            tableView.reloadData()
            noTasksLabel.isHidden = taskList.count > 0 ? true : false
        }
    }
    var project = Project(){
        didSet{
            if !project.title.isEmpty{
                self.title = project.title
            }
            
            taskList = Array(project.tasks)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        self.noTasksLabel.isHidden = !self.taskList.isEmpty
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as? TaskViewController
        if let cell = sender as? TaskTableViewCell{
            destinationViewController?.task = taskList[cell.tag]
            destinationViewController?.isEditingTask = true
        }
        destinationViewController?.delegate = self
        destinationViewController?.project = project
    }
    
    @IBAction func addTask(_ sender: Any) {
        self.performSegue(withIdentifier: "addTask", sender: self)
    }
}

extension ProjectViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as? TaskTableViewCell
        let task : Task = taskList[indexPath.row]
        cell?.setDataWithTask(task: task)
        cell?.tag = indexPath.row
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.performSegue(withIdentifier: "addTask", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: .destructive, title: "Delete") { (action, indexpath) in
            let task = self.taskList[indexPath.row]
            TaskHelper.deleteTask(task: task, projectId: self.project.id) { (success, error) in
                DispatchQueue.main.async {
                    self.taskList = TaskHelper.taskListForProject(project: self.project)
                    self.tableView.reloadData()
                }
            }
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}

extension ProjectViewController : TaskEditor{
    func projectWasUpdated(project: Project) {
        self.project = project
    }
}
