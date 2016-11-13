//
//  UIHelper.swift
//  ProjectPlanner
//
//  Created by Adriana Elizondo on 11/13/16.
//  Copyright © 2016 Adriana Elizondo. All rights reserved.
//

import Foundation
import UIKit

class IndicatorToolbar: UIToolbar {
    lazy var indicatorLayer : CALayer = {
        var layer = CALayer()
        let yPosition = self.frame.height + self.frame.origin.x
        if let firstButton = self.items?[0] as UIBarButtonItem?,
            let view = (firstButton.value(forKey: "view") as? UIView){
            layer.frame = CGRect.init(x: view.frame.origin.x, y: yPosition - 3.0, width: view.bounds.width, height: 3.0)
            layer.backgroundColor = UIColor.orange.cgColor
        }
        
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.addSublayer(indicatorLayer)
    }

    //Change indicator on toolbar
    func animateLayerWithIndex(index: Int){
        if let pressedButton = self.items?[index] as UIBarButtonItem?,
            let view = (pressedButton.value(forKey: "view") as? UIView){
            
            var frame = indicatorLayer.frame
            frame.origin.x = view.frame.origin.x
            frame.size.width = view.bounds.width
            self.indicatorLayer.frame = frame

        }
    }
}
