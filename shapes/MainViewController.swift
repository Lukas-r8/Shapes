//
//  ViewController.swift
//  shapes
//
//  Created by Lucas Alves da Silva on 11/7/18.
//  Copyright © 2018 Lucas Alves da Silva. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    var allOriginalPoints = [Int:(point: CGPoint,controlPoint: CGPoint)]()
    var allPoints = [Int:(viewPoint: viewPoint,controlPoint: viewPoint)]()
    
    
    // scale shape
    var scaleFactor:CGFloat = 1 {
        didSet{
            scaleMatrix = [[scaleFactor,0],
                          [0,scaleFactor]]
        }
    }
    
    lazy var scaleMatrix: [[CGFloat]] = [[scaleFactor,0],
                                         [0,scaleFactor]]

    
    // rotation shape
    var angle:CGFloat = 0 {
        didSet{
            rotationMatrix = [[cos(angle), -sin(angle)],
                              [sin(angle), cos(angle)]]
        }
    }
    
    lazy var rotationMatrix = [[cos(angle), -sin(angle)],
                               [sin(angle), cos(angle)]]
    
    // rotation velocity
    var velocity: CGFloat = 0.1
    
    
    
    
    var imageCenterPoint = CGPoint.zero {
        didSet{
            centerImage.center = imageCenterPoint
        }
    }
    
    let centerImage: UIView = {
        let cnt  = UIView()
        cnt.backgroundColor = UIColor.purple
        cnt.frame.size = CGSize(width: 30, height: 30)
        cnt.layer.cornerRadius = cnt.frame.width / 2
        return cnt
    }()
    
    
    
    

    var lastPoint = CGPoint.zero
    var bezierPath: UIBezierPath!
    
    var shapePoints:CGFloat = 5
    var xRadius: CGFloat = 120
    var yRadius:CGFloat = 120
    var proportion:CGFloat = 1
    
    
    
    lazy var velocitySlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.black
        slider.minimumValue = -0.02
        slider.maximumValue = 0.02
        slider.value = 0
        slider.addTarget(self, action: #selector(changeVelocity), for: .valueChanged)
        return slider
    }()
    
    @objc func changeVelocity(sender: UISlider){
        velocity = CGFloat(sender.value)
    }
    
    
    let shapeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.red
        slider.minimumValue = 2
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
        slider.value = 120
        slider.addTarget(self, action: #selector(changeX), for: .valueChanged)
        return slider
    }()
    
    let ySlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.orange
        slider.minimumValue = 5
        slider.maximumValue = 150
        slider.value = 120
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
        layer.lineWidth = 1
        layer.strokeColor = UIColor.blue.cgColor
        layer.lineJoin = CAShapeLayerLineJoin.round
        layer.fillRule = CAShapeLayerFillRule.evenOdd
        layer.fillColor = UIColor.green.withAlphaComponent(0.5).cgColor
        return layer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUpViews()
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(animations))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        view.addSubview(centerImage)
    }
    
    lazy var display: CADisplayLink = {
        let dis = CADisplayLink(target: self, selector: #selector(rotateAllPoints))
        dis.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        dis.isPaused = true
        return dis
    }()
    
    @objc func animations(tap: UITapGestureRecognizer){

        display.isPaused = !display.isPaused
        
//        if !display.isPaused {angle = 0 }
   
    }

    @objc func rotateAllPoints(){

        let centerX = imageCenterPoint.x
        let centerY = imageCenterPoint.y
        
        
        for i in 0 ..< allOriginalPoints.count {
            let pt = allOriginalPoints[i]!.point
            let cont = allOriginalPoints[i]!.controlPoint
            guard let rotatedPoint = multMatrix(matrixA: rotationMatrix, matrixB: [[pt.x - centerX],[pt.y - centerY]]) else {return}
            guard let rotatedControl = multMatrix(matrixA: rotationMatrix, matrixB: [[cont.x - centerX],[cont.y - centerY]]) else {return}
            
            allPoints[i]!.viewPoint.center = CGPoint(x: rotatedPoint[0][0] + centerX, y: rotatedPoint[1][0] + centerY)
            allPoints[i]!.controlPoint.center = CGPoint(x: rotatedControl[0][0] + centerX , y: rotatedControl[1][0] + centerY)

            shapeLayer.path = updatePath(nil)

            // -0.02 ... +0.02 --> velocity range values
            
            angle += velocity
        }
    }

}

