//
//  viewPoint.swift
//  shapes
//
//  Created by Lucas Alves da Silva on 11/7/18.
//  Copyright © 2018 Lucas Alves da Silva. All rights reserved.
//

import Foundation
import UIKit

class viewPoint: UIView {

    var keyValue: Int

    var isSelectedPoint: Bool = false {
        didSet{
            if isSelectedPoint {
                backgroundColor = .purple
            } else {
                if isControlPoint {
                    backgroundColor = .green
                } else {
                    backgroundColor = .red
                }
            }
        }
    }
    
    lazy var identifierLabel: UILabel = {
        let label = UILabel()
        label.frame.size = frame.size
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor.black
        return label
    }()
    
    
    var isControlPoint = false {
        didSet{
            if isControlPoint{
                backgroundColor = UIColor.green
                identifierLabel.text = "c\(keyValue)"
            }
        }
    }
    
    let controller: MainViewController
    
    required init(controller: MainViewController, keyValue: Int) {
        self.keyValue = keyValue
        self.controller = controller
        super.init(frame: .zero)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    func setUp(){
        frame.size = CGSize(width: 20, height: 20)
        layer.cornerRadius = frame.width / 2
        backgroundColor = UIColor.red
        addGestureRecognizer(UIPanGestureRecognizer(target: controller, action: #selector(controller.changePointPositionIndividually)))
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        identifierLabel.center = center
        identifierLabel.text = keyValue == 0 ? "" : "\(keyValue)"
        addSubview(identifierLabel)
    }
    
    
    
    
    
}




