//
//  TaskViewController.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/10/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

protocol TaskEditor : class{
    func projectWasUpdated(project: Project)
}

class TaskViewController : UIViewController {
    weak var delegate : TaskEditor?
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var deadlineTextField: UITextField!{
        didSet{
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.isTranslucent = true
            toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
            toolBar.sizeToFit()
            
            let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(done))
            
            toolBar.setItems([doneButton], animated: false)
            toolBar.isUserInteractionEnabled = true
            deadlineTextField.inputAccessoryView = toolBar
        }
    }
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var okButton: UIButton!{
        didSet{
            okButton.layer.cornerRadius = 8
            okButton.clipsToBounds = true
        }
    }
    
    var datePickerView = UIDatePicker()
    var isEditingTask : Bool = false
    var task = Task()
    var project = Project()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEditingTask{
            setDataWithTask(task: task)
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        let projectId = project.id
        let dateValue = TaskHelper.doubleValueOfDate(date: datePickerView.date)
        
        if isEditingTask {
            let title = (titleTextField.text?.isEmpty)! ? task.title : titleTextField.text ?? ""
            TaskHelper.patchTask(task: task, projectId: projectId, title: title, deadline: String(dateValue) , completed: statusSwitch.isOn.description){ (success, object) in
                if success{
                    DispatchQueue.main.async {
                        if let project = object as? Project{
                            self.delegate?.projectWasUpdated(project: project)
                        }
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    print("ooops \(object)")
                }
            }

        }else{
            TaskHelper.addTaskWithData(projectId: projectId, title: titleTextField.text ?? "", deadline: datePickerView.date , completed: statusSwitch.isOn){ (success, object) in
                if success{
                    DispatchQueue.main.async {
                        if let project = object as? Project{
                            self.delegate?.projectWasUpdated(project: project)
                        }
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    print("ooops \(object)")
                }
            }
        }
    }
    
    @IBAction func deadLineChange(_ sender: Any) {
        datePickerView.datePickerMode = UIDatePickerMode.date
        (sender as! UITextField).inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(didUpdateDeadLine(datepicker:)), for: .valueChanged)
    }
}

extension TaskViewController{
    func setDataWithTask(task : Task){
        titleTextField.placeholder = task.title
        
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        deadlineTextField.placeholder = TaskHelper.deadlineForTask(task: task)
        statusSwitch.isOn = task.completed
    }
    
    func didUpdateDeadLine(datepicker: UIDatePicker){
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        deadlineTextField.text = dateformatter.string(from: datepicker.date)
    }
    
    func done(){
        didUpdateDeadLine(datepicker: datePickerView)
        self.view.endEditing(true)
    }
    
}
