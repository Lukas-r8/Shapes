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
    
    var keyValue: CGFloat!
    
    required init(controller: MainViewController) {
        super.init(frame: .zero)
        setUp(main: controller)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUp(main: MainViewController){
        frame.size = CGSize(width: 20, height: 20)
        layer.cornerRadius = frame.width / 2
        backgroundColor = UIColor.red
        addGestureRecognizer(UIPanGestureRecognizer(target: main, action: #selector(main.changePointPositionIndividually)))

    }

}
