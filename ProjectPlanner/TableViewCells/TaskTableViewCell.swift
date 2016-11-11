//
//  TaskTableViewCell.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/10/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class TaskTableViewCell : UITableViewCell {
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var statusImage: UIImageView!{
        didSet{
            statusImage.layer.cornerRadius = statusImage.frame.width / 2
            statusImage.clipsToBounds = true
        }
    }
    
    func setDataWithTask(task :Task){
        taskName.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        deadline.text = formatter.string(from: task.deadline)
        
        statusImage.backgroundColor = task.completed ? UIColor.green : UIColor.red
    }

    
}
