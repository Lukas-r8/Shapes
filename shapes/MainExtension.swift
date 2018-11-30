//
//  mainExtension.swift
//  shapes
//
//  Created by Lucas Alves da Silva on 11/7/18.
//  Copyright © 2018 Lucas Alves da Silva. All rights reserved.
//

import Foundation
import UIKit



extension MainViewController {
    // SLIDER EXTENSIONS....
    @objc func changeX(sender: UISlider){
        xRadius = CGFloat(floor(sender.value))
        shapeLayer.path = drawCircle(initialPoint: view.center)
        valueLabel.text = "Number of faces: \(floor(shapeSlider.value))"
    }
    
    @objc func changeY(sender: UISlider){
        yRadius = CGFloat(floor(sender.value))
        shapeLayer.path = drawCircle(initialPoint: view.center)
        valueLabel.text = "Number of faces: \(floor(shapeSlider.value))"
    }
    
    @objc func changeNumberOfFaces(sender: UISlider){
        shapePoints = CGFloat(floor(shapeSlider.value))
        shapeLayer.path = drawCircle(initialPoint: view.center)
        valueLabel.text = "Number of faces: \(floor(shapeSlider.value))"
    }
    
    @objc func changeProportion(gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .began:
            fallthrough
        case .changed:
            scaleFactor = gesture.scale
            updateProportion()
        case .ended:
            updateAllOriginalPoints()
        default:
            break
        }
        
       
 
        valueLabel.text = "Number of faces: \(floor(shapeSlider.value))"
    }
    
    func updateProportion(){
        let centerX = imageCenterPoint.x
        let centerY = imageCenterPoint.y
        
        for (index) in 0 ..< allOriginalPoints.count{
            
            let point = allOriginalPoints[index]!.point
            let control = allOriginalPoints[index]!.controlPoint
            
            guard let scaledPoints = multMatrix(matrixA: scaleMatrix, matrixB: [[point.x - centerX],[point.y - centerY]]) else {return}
            guard let scaledControlPoints = multMatrix(matrixA: scaleMatrix, matrixB: [[control.x - centerX],[control.y - centerY]]) else {return}
            
           
            
            UIView.animate(withDuration: 1, animations: {
                self.allPoints[index]?.viewPoint.center = CGPoint(x: scaledPoints[0][0] + centerX, y: scaledPoints[1][0] + centerY)
                self.allPoints[index]?.controlPoint.center = CGPoint(x: scaledControlPoints[0][0] + centerX, y: scaledControlPoints[1][0] + centerY)
            })
            updatePath(nil)
            
            
        }
        
//        updateAllOriginalPoints()
    }
    
    
    // CONSTRAINT EXTENSIONS...
    func setUpViews(){
        view.layer.addSublayer(shapeLayer)
        shapeLayer.path = drawCircle(initialPoint: view.center)
        view.addSubview(shapeSlider)
        view.addSubview(valueLabel)
        view.addSubview(xSlider)
        view.addSubview(ySlider)
        view.addSubview(microphoneButton)
        
        view.addSubview(velocitySlider)
        
        xSlider.transform = CGAffineTransform(rotationAngle: 90 * .pi / 180)
        ySlider.transform = CGAffineTransform(rotationAngle: 90 * .pi / 180)
        
        xSlider.widthAnchor.constraint(equalToConstant: 400).isActive = true
        xSlider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        xSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        xSlider.centerXAnchor.constraint(equalTo: view.rightAnchor,constant: -30).isActive = true
        
        ySlider.widthAnchor.constraint(equalToConstant: 400).isActive = true
        ySlider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        ySlider.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        ySlider.centerXAnchor.constraint(equalTo: view.leftAnchor,constant: 30).isActive = true
        
        shapeSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        shapeSlider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        shapeSlider.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        shapeSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        valueLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        valueLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        valueLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        velocitySlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        velocitySlider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        velocitySlider.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 10).isActive = true
        velocitySlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        microphoneButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        microphoneButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        microphoneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        microphoneButton.bottomAnchor.constraint(equalTo: shapeSlider.topAnchor, constant: -10).isActive = true
    }
    
    
    
    
    func drawCircle(initialPoint: CGPoint) -> CGPath {
        allOriginalPoints = [Int:(point: CGPoint, controlPoint: CGPoint)]()
        allPoints = [Int:(viewPoint: viewPoint,controlPoint: viewPoint)]()
        view.subviews.forEach { (point) in
            if let point = point as? viewPoint {
                point.removeFromSuperview()
            }
        }
        
        let precision = 360/shapePoints
        bezierPath = UIBezierPath()
        bezierPath.lineWidth = 5
        
        for (index,i) in stride(from: CGFloat(0), through: CGFloat(360), by: precision).enumerated(){
            let radians = CGFloat(i) * CGFloat.pi / 180
            let x = initialPoint.x + (xRadius * proportion) * cos(radians)
            let y = initialPoint.y + (yRadius * proportion) * sin(radians)
            
            let currentPoint = CGPoint(x: x, y: y)
            let midPoint = CGPoint(x: (lastPoint.x * 0.5 + currentPoint.x * 0.5) , y: (lastPoint.y * 0.5 + currentPoint.y * 0.5))
            
            let point = viewPoint(controller: self, keyValue: index)
            point.center = currentPoint
            
            let controlPoint = viewPoint(controller: self, keyValue: index)
            controlPoint.center = midPoint
            controlPoint.isControlPoint = true
            
            view.addSubview(point)
            view.addSubview(controlPoint)
            allOriginalPoints[index] = (point: currentPoint, controlPoint: midPoint)
            allPoints[index] = (viewPoint: point, controlPoint: controlPoint)
            
            
            if allPoints.count <= 1 {
                bezierPath.move(to: currentPoint)
            } else {
                bezierPath.addQuadCurve(to: allPoints[index]!.viewPoint.center, controlPoint: allPoints[index]!.controlPoint.center)
            }
            
            
            lastPoint = currentPoint
        }
        
        let firstControlPoint = allPoints[0]!.controlPoint
        firstControlPoint.removeFromSuperview()
        
        let firstView = allPoints[0]!.viewPoint
        let lastView = allPoints[allPoints.count - 1]!.viewPoint
        firstView.center = lastView.center
        bezierPath.close()
        
        return bezierPath.cgPath
    }
    
    @objc func changePointPositionIndividually(pan: UIPanGestureRecognizer){
        guard let viewTouched = pan.view as? viewPoint else {return}
        let location = pan.location(in: view)
        switch pan.state {
        case .began:
            break
        case .changed:

            if viewTouched.isControlPoint {
                let controlToBeChanged = allPoints[viewTouched.keyValue]!.controlPoint
                controlToBeChanged.center = location
                updatePath(nil)
                centerImage.center = imageCenterPoint

            } else {
                let viewToBeChanged = allPoints[viewTouched.keyValue]!.viewPoint
                viewToBeChanged.center = location
                updatePath(nil)
            }
        case .ended:
            updateAllOriginalPoints()

        default:
            break
        }
    }
    
    func updateAllOriginalPoints(){
        timerUpdate?.invalidate()
        timerUpdate = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
            self.allOriginalPoints = [Int:(point: CGPoint, controlPoint: CGPoint)]()
            self.allPoints.forEach { (dict) in self.allOriginalPoints[dict.key] = (point: dict.value.viewPoint.center, controlPoint: dict.value.controlPoint.center)}
            self.timerUpdate?.invalidate()
        })
    }
    
    func updatePath(_ viewToBeChanged: viewPoint?){
        var firstIteration = true
        
        bezierPath = UIBezierPath()
        
        var xSum = CGFloat(0)
        var ySum = CGFloat(0)
        let divisor =  CGFloat(allOriginalPoints.count * 2 - 2)

        for index in 0 ..< allPoints.count {
            if firstIteration{
                bezierPath.move(to: allPoints[allPoints.count - 1]!.viewPoint.center)
                firstIteration = !firstIteration
                continue
            }
            
            let crestPoint = allPoints[index]!.controlPoint.center
            let fromPoint = index == 1 ? allPoints[allPoints.count - 1]!.viewPoint.center : allPoints[index - 1]!.viewPoint.center
            let toPoint = allPoints[index]!.viewPoint.center
            let fromCrestToX = fromPoint.x - crestPoint.x
            let fromCrestToY = fromPoint.y - crestPoint.y
            let toTouchX = toPoint.x - crestPoint.x
            let toTouchY = toPoint.y - crestPoint.y
            let Ra = sqrt(fromCrestToX * fromCrestToX + fromCrestToY * fromCrestToY)
            let Rb = sqrt(toTouchX * toTouchX + toTouchY * toTouchY)
            let pointX = crestPoint.x - sqrt(Ra * Rb) / 2 * ((fromPoint.x - crestPoint.x) / Ra + (toPoint.x - crestPoint.x) / Rb)
            let pointY = crestPoint.y - sqrt(Ra * Rb) / 2 * ((fromPoint.y - crestPoint.y) / Ra + (toPoint.y - crestPoint.y) / Rb)
            
            let control = CGPoint(x: pointX, y: pointY)

            xSum += allOriginalPoints[index]!.controlPoint.x + allOriginalPoints[index]!.point.x
            ySum += allOriginalPoints[index]!.controlPoint.y + allOriginalPoints[index]!.point.y
            
            imageCenterPoint = CGPoint(x: xSum / divisor, y: ySum / divisor)


            bezierPath.addQuadCurve(to: allPoints[index]!.viewPoint.center, controlPoint: control)
        }
        
        
        

        let firstView = allPoints[0]!.viewPoint
        let lastView = allPoints[allPoints.count - 1]!.viewPoint
        firstView.center = lastView.center
        bezierPath.close()
        
        
        shapeLayer.path = bezierPath.cgPath
    }
    
   
    
    
    
    // Matrix multiplication...
    
    
    func multMatrix(matrixA: [[CGFloat]],matrixB:[[CGFloat]]) -> [[CGFloat]]?{
        // check possible inconsistencies between matrices...
        if matrixA.count <= 0 || matrixB.count <= 0 {print("error: matrices should contain at least 1 value"); return nil}
        
        for i in 1 ..< matrixA.count {
            if matrixA[i - 1].count != matrixA[i].count {print("error: number of items in matrixA doens't match up");return nil}
        }
        for i in 1 ..< matrixB.count {
            if matrixB[i - 1].count != matrixB[i].count {print("error: number of items in matrixB doens't match up");return nil}
        }
        if matrixA[0].count != matrixB.count {print("error: collums in A don't match rows in B --> func multMatrix");return nil}
        ///////////////////////////////////////////////////////
        
        var result = [[CGFloat]]()
        
        for i in 0 ..< matrixA.count {
            var childArrayResult = [CGFloat]()
            for iteration in 0 ..< matrixB[0].count {
                var tempResult: CGFloat = 0
                for (a,valueA) in matrixA[i].enumerated(){
                    let res = valueA * matrixB[a][iteration]
                    tempResult += res
                }
                childArrayResult.append(tempResult)
            }
            result.append(childArrayResult)
        }
        
      
        return result
    }
    
    
    
}
