//
//  ViewController.swift
//  shapes
//
//  Created by Lucas Alves da Silva on 11/7/18.
//  Copyright © 2018 Lucas Alves da Silva. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var allPointsAdded = [[CGFloat:viewPoint]]()
    var bezierPath: UIBezierPath!
    
    let shapeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.red
        slider.minimumValue = 0
        slider.maximumValue = 70
        slider.value = 5
        slider.addTarget(self, action: #selector(changeNumberOfFaces), for: .valueChanged)
        return slider
    }()
    
    let proportionSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.thumbTintColor = UIColor.blue
        slider.maximumValue = 1
        slider.value = 1
        slider.addTarget(self, action: #selector(changeProportion), for: .valueChanged)
        return slider
    }()
    
    let xSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.green
        slider.minimumValue = 5
        slider.maximumValue = 150
        slider.value = 5
        slider.addTarget(self, action: #selector(changeX), for: .valueChanged)
        return slider
    }()
    
   
    
    let ySlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.orange
        slider.minimumValue = 5
        slider.maximumValue = 150
        slider.value = 5
        slider.addTarget(self, action: #selector(changeY), for: .valueChanged)
        return slider
    }()
    

    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "FacesNumber: \(floor(shapeSlider.value)) x: \(floor(xSlider.value * proportionSlider.value)) y:\(floor(ySlider.value * proportionSlider.value))"
        label.textColor = UIColor.black
        return label
    }()
    
    let shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 5
        layer.strokeColor = UIColor.blue.cgColor
        layer.lineJoin = CAShapeLayerLineJoin.round
        layer.fillColor = UIColor.clear.cgColor
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpViews()
    }
    
    
   
    
    func drawCircle(initialPoint:CGPoint ,radiusX: CGFloat,radiusY: CGFloat,numberOfPoints:CGFloat) -> CGPath {
        allPointsAdded = [[CGFloat:viewPoint]]()
        var iteration = 0
        view.subviews.forEach { (point) in
            if let point = point as? viewPoint {
                point.removeFromSuperview()
            }
        }
        
        let precision = 360/numberOfPoints
        bezierPath = UIBezierPath()
        bezierPath.lineWidth = 5
        bezierPath.move(to: CGPoint(x: initialPoint.x + radiusX, y: initialPoint.y))
        
        for i in stride(from: CGFloat(0), through: CGFloat(360), by: precision){
            let radians = CGFloat(i) * CGFloat.pi/180
            let x = initialPoint.x + radiusX * cos(radians)
            let y = initialPoint.y + radiusY * sin(radians)
            
            
            let point = viewPoint(controller: self)
            point.center = CGPoint(x: x, y: y)
            point.keyValue = i
            view.addSubview(point)
            allPointsAdded.append([i:point])
            
            bezierPath.addLine(to: allPointsAdded[iteration][i]?.center ?? point.center)
            iteration += 1
        }
        
        let lastView = allPointsAdded.last?.first?.value
        lastView?.removeFromSuperview()
        allPointsAdded.removeLast()
        bezierPath.close()
        return bezierPath.cgPath
    }
    
    @objc func changePointPositionIndividually(pan: UIPanGestureRecognizer){
        guard let viewTouched = pan.view as? viewPoint else {return}
        let location = pan.location(in: view)
        switch pan.state {
            case .changed:
                var index = 0
                for (i,dict) in allPointsAdded.enumerated(){
                    if dict.first?.value.keyValue == viewTouched.keyValue{
                       index = i
                    }
                }
                guard let viewToBeChanged = allPointsAdded[index].first?.value else {return}
                viewToBeChanged.center = location
                shapeLayer.path = updatePath(updatedView: viewToBeChanged)

            default:
                print("default")
            
        }
    }
    
    func updatePath(updatedView: viewPoint) -> CGPath {
        var firstIteration = true
        bezierPath = UIBezierPath()
        allPointsAdded.forEach { (dict) in
            if firstIteration{
                bezierPath.move(to: (dict.first?.value.center)!)
                firstIteration = !firstIteration
            }
            bezierPath.addLine(to: (dict.first?.value.center)!)
        }
        
        bezierPath.close()
        return bezierPath.cgPath
    }
    
    

}

