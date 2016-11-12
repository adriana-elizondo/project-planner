//
//  ProjectTableViewCell.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/9/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class ProjectTableViewCell : UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var completedImageView: UIImageView!
    @IBOutlet weak var pendingImageView: UIImageView!
    
    var completedTasks : [Task]
    var pendingTasks : [Task]
    
    required init?(coder aDecoder: NSCoder) {
        completedTasks = [Task]()
        pendingTasks = [Task]()
        
        super.init(coder: aDecoder)
    }
   
    func setDataWithProject(project :Project){
        name.text = project.title
        self.completedTasks = ProjectHelper.completedTasksForProject(project: project)
        self.pendingTasks = ProjectHelper.pendingTasksForProject(project: project)
        
        self.completedLabel.text = String(self.completedTasks.count)
        self.pendingLabel.text = String(self.pendingTasks.count)
    }
    
}
