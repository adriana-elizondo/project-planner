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
            noProjectsLabel.isHidden = projectList.count > 0 ? true : false
            //On the main thread because it involves UI
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var tableView : UITableView!{
        didSet{
            tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var noProjectsLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getProjects()
    }
}

//Logic
extension ProjectListViewController{
    func getProjects(){
        let persistedList = Parser.projectList()
        guard persistedList.count > 0 else {
            NetworkHelper.getDataWithDomain(domain: "projects") { (success, result, error) in
                if success{
                    Parser.parseAndPersistProjectList(jsonArray: result as? [Any], completion: { (projects) in
                        self.projectList = Array(projects)
                    })
                }
            }
            return
        }
        
        projectList = Array(persistedList)
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
        cell?.name.text = project.title
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
}
