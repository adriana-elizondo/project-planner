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
    var project = Project(){
        didSet{
            if !project.title.isEmpty{
                self.title = project.title
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
}
