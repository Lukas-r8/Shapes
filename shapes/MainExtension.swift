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
        let shapeValue: CGFloat = CGFloat(floor(shapeSlider.value))
        let xRadius = CGFloat(floor(xSlider.value * proportionSlider.value))
        let yRadius = CGFloat(floor(ySlider.value * proportionSlider.value))
        
        
        shapeLayer.path = drawCircle(initialPoint: view.center, radiusX: xRadius, radiusY: yRadius, numberOfPoints: shapeValue)
        valueLabel.text = "FacesNumber: \(floor(shapeSlider.value)) x: \(floor(xSlider.value * proportionSlider.value)) y:\(floor(ySlider.value * proportionSlider.value))"
        
    }
    
    @objc func changeY(sender: UISlider){
        let shapeValue: CGFloat = CGFloat(floor(shapeSlider.value))
        let xRadius = CGFloat(floor(xSlider.value * proportionSlider.value))
        let yRadius = CGFloat(floor(ySlider.value * proportionSlider.value))
        
        
        shapeLayer.path = drawCircle(initialPoint: view.center, radiusX: xRadius, radiusY: yRadius, numberOfPoints: shapeValue)
        valueLabel.text = "FacesNumber: \(floor(shapeSlider.value)) x: \(floor(xSlider.value * proportionSlider.value)) y:\(floor(ySlider.value * proportionSlider.value))"
        
    }
    
    @objc func changeNumberOfFaces(sender: UISlider){
        
        let shapeValue: CGFloat = CGFloat(floor(shapeSlider.value))
        let xRadius = CGFloat(floor(xSlider.value * proportionSlider.value))
        let yRadius = CGFloat(floor(ySlider.value * proportionSlider.value))
        
        
        shapeLayer.path = drawCircle(initialPoint: view.center, radiusX: xRadius, radiusY: yRadius, numberOfPoints: shapeValue)
        
        valueLabel.text = "FacesNumber: \(floor(shapeSlider.value)) x: \(floor(xSlider.value * proportionSlider.value)) y:\(floor(ySlider.value * proportionSlider.value))"
        
        
        
    }
    
    @objc func changeProportion(sender: UISlider){
        let shapeValue: CGFloat = CGFloat(floor(shapeSlider.value))
        let xRadius = CGFloat(floor(xSlider.value * proportionSlider.value))
        let yRadius = CGFloat(floor(ySlider.value * proportionSlider.value))
        
        
        shapeLayer.path = drawCircle(initialPoint: view.center, radiusX: xRadius, radiusY: yRadius, numberOfPoints: shapeValue)
        
        valueLabel.text = "FacesNumber: \(floor(shapeSlider.value)) x: \(floor(xSlider.value * proportionSlider.value)) y:\(floor(ySlider.value * proportionSlider.value))"
        
    }
    
    
    // CONSTRAINT EXTENSIONS...
    func setUpViews(){
        view.layer.addSublayer(shapeLayer)
        shapeLayer.path = drawCircle(initialPoint: view.center, radiusX: CGFloat(xSlider.value * proportionSlider.value), radiusY: CGFloat(ySlider.value * proportionSlider.value), numberOfPoints: CGFloat(shapeSlider.value))
        view.addSubview(shapeSlider)
        view.addSubview(proportionSlider)
        view.addSubview(valueLabel)
        view.addSubview(xSlider)
        view.addSubview(ySlider)
        
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
        
        proportionSlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        proportionSlider.heightAnchor.constraint(equalToConstant: 40).isActive = true
        proportionSlider.bottomAnchor.constraint(equalTo: shapeSlider.topAnchor, constant: -10).isActive = true
        proportionSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        valueLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
        valueLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        valueLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
