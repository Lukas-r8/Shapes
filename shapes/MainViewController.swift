//
//  ViewController.swift
//  shapes
//
//  Created by Lucas Alves da Silva on 11/7/18.
//  Copyright © 2018 Lucas Alves da Silva. All rights reserved.
//

import UIKit

class MainViewController: UIViewController{
    var timerUpdate: Timer?

    
    var prevSelectedPoint = (value: 0, isControl: false )
    
    
    var selectedPoint = (value: 0, isControl: false ) {
        didSet{
            updateSelectedPoint()
        }
    }
    

    
    var allOriginalPoints = [(point: CGPoint,controlPoint: CGPoint)]()
    var allPoints = [(viewPoint: viewPoint,controlPoint: viewPoint)]()
    
    var speechDelegate : VocalCommandController?
    
    var recordedText = ""
    
    lazy var microphoneButton: UIButton = {
        let mic = UIButton()
        mic.translatesAutoresizingMaskIntoConstraints = false
        mic.backgroundColor = UIColor.black
        mic.layer.cornerRadius = 40
        mic.setTitle("Registra", for: UIControl.State.normal)
//        mic.addTarget(self, action: #selector(microphoneTapped), for: UIControl.Event.touchUpInside)
        return mic
    }()
    
    
    
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
    var velocity: CGFloat = 0
    
    
    
    
    var imageCenterPoint = CGPoint.zero {
        didSet{
            centerImage.center = imageCenterPoint
        }
    }
    
    let centerImage: UIView = {
        let cnt  = UIView()
        cnt.backgroundColor = UIColor.purple
        cnt.frame.size = CGSize(width: 15, height: 15)
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
    
//    let proportionSlider: UISlider = {
//        let slider = UISlider()
//        slider.translatesAutoresizingMaskIntoConstraints = false
//        slider.minimumValue = 0
//        slider.thumbTintColor = UIColor.blue
//        slider.maximumValue = 2
//        slider.value = 1
//        slider.alpha = 0
//        slider.addTarget(self, action: #selector(changeProportion), for: .valueChanged)
//        return slider
//    }()
    
    let xSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.green
        slider.minimumValue = 5
        slider.maximumValue = 150
        slider.value = 120
        slider.alpha = 0
        slider.addTarget(self, action: #selector(changeX), for: .valueChanged)
        return slider
    }()
    
    let ySlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.orange
        slider.minimumValue = 5
        slider.alpha = 0
        slider.maximumValue = 150
        slider.value = 120
        slider.addTarget(self, action: #selector(changeY), for: .valueChanged)
        return slider
    }()

    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "Number of points: \(floor(shapeSlider.value))"
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
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(changeProportion))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(changeRotation))
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(rotationGesture)
        
        speechDelegate = VocalCommandController(controller: self)
        
        view.addSubview(centerImage)
        speechDelegate!.initRecording()

    }
    
  
    
    
    @objc func changeRotation(gesture: UIRotationGestureRecognizer){
        
        // radians = angle * pi / 180 --> (radians * 180) / pi = angle
        
        switch gesture.state {
        case .began:
            fallthrough
        case .changed:
            angle = gesture.rotation
            rotateAllPoints()
        case .ended:
            print("updating roattion points")
            updateAllOriginalPoints()
        default:
            break
        }
        
        
    }
    
    lazy var display: CADisplayLink = {
        let dis = CADisplayLink(target: self, selector: #selector(rotateAllPoints))
        dis.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        dis.isPaused = true
        return dis
    }()

    @objc func animations(tap: UITapGestureRecognizer){

//        display.isPaused = !display.isPaused
//        if !display.isPaused {angle = 0 }

    }

    @objc func rotateAllPoints(){

        let centerX = imageCenterPoint.x
        let centerY = imageCenterPoint.y
        
        
        for i in 0 ..< allOriginalPoints.count {
            let pt = allOriginalPoints[i].point
            let cont = allOriginalPoints[i].controlPoint
            guard let rotatedPoint = multMatrix(matrixA: rotationMatrix, matrixB: [[pt.x - centerX],[pt.y - centerY]]) else {return}
            guard let rotatedControl = multMatrix(matrixA: rotationMatrix, matrixB: [[cont.x - centerX],[cont.y - centerY]]) else {return}
            
                self.allPoints[i].viewPoint.center = CGPoint(x: rotatedPoint[0][0] + centerX, y: rotatedPoint[1][0] + centerY)
                self.allPoints[i].controlPoint.center = CGPoint(x: rotatedControl[0][0] + centerX , y: rotatedControl[1][0] + centerY)

            updatePath(nil)

            // -0.02 ... +0.02 --> velocity range values
            if !display.isPaused {
                angle += velocity
            }
            
        }
        
//        updateAllOriginalPoints()
    }
    
    
    func updateSelectedPoint() {
        if !(selectedPoint == prevSelectedPoint) {
            if selectedPoint.isControl {
                 allPoints[selectedPoint.value].controlPoint.isSelectedPoint = true
            } else {
                allPoints[selectedPoint.value].viewPoint.isSelectedPoint = true
            }

            if prevSelectedPoint.isControl {
                allPoints[prevSelectedPoint.value].controlPoint.isSelectedPoint = false
            } else {
                allPoints[prevSelectedPoint.value].viewPoint.isSelectedPoint = false
            }
        }
        prevSelectedPoint = selectedPoint
    }
    
    
    
    func addPointBetween(_ index1: Int,_ index2: Int,_ isControl: Bool){
        
        
        
        
        
        
        
        
        
    }
    
    
    

}




























//extension MainViewController: SFSpeechRecognizerDelegate {
//
//    func initRecording(){
//        microphoneButton.isEnabled = false
//        speechRecognizer?.delegate = self
//
//        SFSpeechRecognizer.requestAuthorization { (authStatus) in
//
//            var isButtonEnabled = false
//
//            switch authStatus {
//            case .authorized:
//                isButtonEnabled = true
//
//            case .denied:
//                isButtonEnabled = false
//                print("User denied access to speech recognition")
//
//            case .restricted:
//                isButtonEnabled = false
//                print("Speech recognition restricted on this device")
//
//            case .notDetermined:
//                isButtonEnabled = false
//                print("Speech recognition not yet authorized")
//            }
//
//            OperationQueue.main.addOperation() {
//                self.microphoneButton.isEnabled = isButtonEnabled
//            }
//        }
//    }
//
//
//
//    @objc func microphoneTapped(_ sender: UIButton) {
//
//        if speechDelegate!.audioEngine.isRunning {
//            speechDelegate!.audioEngine.stop()
//            speechDelegate!.recognitionRequest?.endAudio()
//            microphoneButton.isEnabled = false
//            microphoneButton.setTitle("Registra", for: .normal)
//        } else {
//            speechDelegate!.startRecording()
//            microphoneButton.setTitle("Stop", for: .normal)
//        }
//
//    }
//
//
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        if available {
//            microphoneButton.isEnabled = true
//        } else {
//            microphoneButton.isEnabled = false
//        }
//    }
//
//
//    func startRecording() {
//
//        if recognitionTask != nil {
//            recognitionTask?.cancel()
//            recognitionTask = nil
//        }
//
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
//            try audioSession.setMode(AVAudioSession.Mode.measurement)
//            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//        } catch let err {
//            print("audioSession properties weren't set because of an error. error description:", err.localizedDescription)
//        }
//
//        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
//
//        let inputNode = audioEngine.inputNode
//
//
//        guard let recognitionRequest = recognitionRequest else {fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")}
//
//        recognitionRequest.shouldReportPartialResults = true
//
//        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
//
//            var isFinal = false
//
//
//
//            if result != nil {
//
//                self.valueLabel.text = result?.bestTranscription.formattedString
//                isFinal = (result?.isFinal)!
//            }
//
//
//            if error != nil || isFinal {
//                self.audioEngine.stop()
//                inputNode.removeTap(onBus: 0)
//
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
//
//                self.microphoneButton.isEnabled = true
//                guard let str = self.valueLabel.text?.lowercased() else {return}
//                self.recordedText = str
//
//                self.valueLabel.text = ""
//
//                self.recognizeVocalCommand()
//
//
//
//            }
//        })
//
//
//
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
//            self.recognitionRequest?.append(buffer)
//        }
//
//        audioEngine.prepare()
//
//        do {
//            try audioEngine.start()
//        } catch let error {
//            print("audioEngine couldn't start because of an error.", error.localizedDescription)
//            return
//        }
//
//        valueLabel.text = "In ascolto..."
//
//    }
//
//
//
//    func recognizeVocalCommand() {
//
//        var numbersFromRecText = [CGFloat]()
//        let strArray = recordedText.replacingOccurrences(of: ",", with: ".").split(separator: Character(" "))
//
//        for word in strArray {
//            if let number = Float(word) {
//                numbersFromRecText.append(CGFloat(number))
//            }
//            if let numFromStr = formateStrToNumber(str: String(word).lowercased()) {
//                numbersFromRecText.append(numFromStr)
//            }
//        }
//
//        // manage vocal commands
//
//        print("recorded text:",recordedText)
//        print("numbers:",numbersFromRecText)
//
//        if recordedText.contains("scale"){
//            if numbersFromRecText.count != 0 {
//                let proportionValue = CGFloat(numbersFromRecText[0])
//                scaleFactor = proportionValue
//                updateProportion()
//            }
//        } else if recordedText.contains("rotate") {
//            if numbersFromRecText.count != 0 {
//                let radians = numbersFromRecText[0] * CGFloat.pi / 180
//                angle = radians
//                rotateAllPoints()
//                // ???????????????????????????????? maybe remove the line down below
//                updateAllOriginalPoints()
//                //??????????????????????????????????????
//            }
//        } else if recordedText.contains("draw") {
//            if numbersFromRecText.count != 0 {
//                let number = floor(numbersFromRecText[0])
//                shapePoints = number
//                shapeSlider.setValue(Float(number), animated: true)
//                shapeLayer.path = drawCircle(initialPoint: self.view.center)
//            }
//        } else if recordedText.contains("select"){
//            if numbersFromRecText.count > 0 && recordedText.contains("control") && recordedText.contains("number") {
//                selectedPoint = (value: Int(numbersFromRecText[0]), isControl: true)
//            } else if numbersFromRecText.count > 0 && recordedText.contains("number") {
//                selectedPoint = (value: Int(numbersFromRecText[0]), isControl: false)
//            }
//        }
//    }
//
//    func formateStrToNumber(str: String) -> CGFloat?{
//        let formatter = NumberFormatter()
//        formatter.locale = Locale(identifier: "en")
//        formatter.numberStyle = NumberFormatter.Style.spellOut
//        guard let number = formatter.number(from: str.lowercased()) else {return nil}
//        return CGFloat(truncating: number)
//    }
//
//
//
//
//
//}
