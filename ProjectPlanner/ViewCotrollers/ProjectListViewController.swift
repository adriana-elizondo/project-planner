//
//  ProjectListViewController.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/9/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class ProjectListViewController: UIViewController {
    var projectList = [Project](){
        didSet{
            noProjectsLabel.isHidden = !projectList.isEmpty
            self.tableView.reloadData()
        }
    }
    
    @IBOutlet weak var toolBar: IndicatorToolbar!
    @IBOutlet weak var tableView : UITableView!{
        didSet{
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var noProjectsLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "My Projects"
        projectList = ProjectHelper.projectList()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as? ProjectViewController
        if let cell = sender as? ProjectTableViewCell{
            destinationViewController?.project = projectList[cell.tag]
        }
    }
    
}

//Logic
extension ProjectListViewController{
    @IBAction func addProject(){
        let alertController = UIAlertController.init(title: "New Project", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel){ _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        
        let addAction = UIAlertAction.init(title: "Add", style: .default) { _ in
            
            let titleTextField = alertController.textFields![0] as UITextField
            ProjectHelper.addProjectWithTitle(title: titleTextField.text ?? "") { (success, error) in
                if success{
                    print("success")
                    self.projectList = ProjectHelper.projectList()
                }else{
                    print("ooops \(error)")
                }
            }
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(addAction)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Title"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                addAction.isEnabled = !(textField.text?.isEmpty)!
            }
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func refreshProjects(){
        ProjectHelper.getProjectsWithCompletion() { (projects) in
            if let refreshedProjects = projects {
                self.projectList = refreshedProjects
            }
        }
    }
    
    @IBAction func sortByName(){
        projectList = ProjectHelper.sortByName(projects: projectList)
        toolBar.animateLayerWithIndex(index: 0)
    }
    
    @IBAction func sortByCompleted(){
        projectList = ProjectHelper.sortByCompleted(projects: projectList)
        toolBar.animateLayerWithIndex(index: 2)
        
    }
    
    @IBAction func sortByPending(){
        projectList = ProjectHelper.sortByPending(projects: projectList)
        toolBar.animateLayerWithIndex(index: 4)
        
    }
}

extension ProjectListViewController : UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectCell") as? ProjectTableViewCell
        let project : Project = projectList[indexPath.row]
        cell?.setDataWithProject(project: project)
        cell?.tag = indexPath.row
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        self.performSegue(withIdentifier: "tasksSegue", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: .destructive, title: "Delete") { (action, indexpath) in
            let project = self.projectList[indexPath.row]
            ProjectHelper.deleteProject(project: project){ (success, error) in
                self.projectList = ProjectHelper.projectList()
            }
        }
        
        let changeName = UITableViewRowAction.init(style: .normal, title: "Rename"){ (action, indexpath) in
            let project = self.projectList[indexPath.row]
            
            let alertController = UIAlertController.init(title: "New name", message: "", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel){ _ in
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(cancelAction)
            
            let editAction = UIAlertAction.init(title: "New name", style: .default, handler: { (action) in
                ProjectHelper.patchProject(project: project, title: alertController.textFields?.first?.text ?? project.title){ (success, error) in
                    self.projectList = ProjectHelper.projectList()
                }
            })
            
            alertController.addTextField { (textField) in
                textField.placeholder = project.title
            }
            
            alertController.addAction(editAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        return [delete, changeName]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
}
