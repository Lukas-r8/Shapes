//
//  VocalCommandController.swift
//  shapes
//
//  Created by Ottavio Gelone on 30/11/2018.
//  Copyright © 2018 Lucas Alves da Silva. All rights reserved.
//

import UIKit
import Speech


class VocalCommandController: NSObject, SFSpeechRecognizerDelegate {
    
    let mainVC : MainViewController
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "it-IT"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    init(controller: MainViewController) {
        self.mainVC = controller
        super.init()
    }
    
    
    func startRecording() {
        
        if self.recognitionTask != nil {
            self.recognitionTask?.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode

        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.mainVC.valueLabel.text = result?.bestTranscription.formattedString.lowercased()
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.mainVC.microphoneButton.isEnabled = true
                
                self.mainVC.recordedText = self.mainVC.valueLabel.text!
                
                self.mainVC.valueLabel.text = ""

                
                self.recognizeVocalCommand()
    
                
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        self.mainVC.valueLabel.text = "In ascolto..."
        
    }
    
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.mainVC.microphoneButton.isEnabled = true
        } else {
            self.mainVC.microphoneButton.isEnabled = false
        }
    }
    
    
    func recognizeVocalCommand() {
        
        print("RECCOMMAND")
        
        var numbersFromRecText = [CGFloat]()
        let strArray = mainVC.recordedText.replacingOccurrences(of: ",", with: ".").split(separator: Character(" "))
        
        for word in strArray {
            if let number = Float(word) {
                numbersFromRecText.append(CGFloat(number))
            }
            if let numFromStr = formateStrToNumber(str: String(word).lowercased()) {
                numbersFromRecText.append(numFromStr)
            }
        }
        
        //       manage vocal commands
        
        print("recorded text:",mainVC.recordedText)
        print("numbers:",numbersFromRecText)
        print("REC: \(mainVC.recordedText)")
        if mainVC.recordedText.contains("scala"){
            print("SCALA")
            if numbersFromRecText.count != 0 {
                let proportionValue = CGFloat(numbersFromRecText[0])
                mainVC.scaleFactor = proportionValue
                mainVC.updateProportion()
            }
        } else if mainVC.recordedText.contains("ruota") {
            print("RUOTA")
            if numbersFromRecText.count != 0 {
                let radians = numbersFromRecText[0] * CGFloat.pi / 180
                mainVC.angle = radians
                mainVC.rotateAllPoints()
            }
        } else if mainVC.recordedText.contains("disegna") {
            print("DISEGNA")
            if numbersFromRecText.count != 0 {
                let number = floor(numbersFromRecText[0])
                mainVC.shapePoints = number
                mainVC.shapeSlider.setValue(Float(number), animated: true)
                mainVC.shapeLayer.path = mainVC.drawCircle(initialPoint: mainVC.view.center)
            }
        }
        
    }
    
    
    
    
    func initRecording() {
        
        
        
        self.mainVC.microphoneButton.isEnabled = false
        
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.mainVC.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    
    
    func formateStrToNumber(str: String) -> CGFloat?{
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "it-IT")
        formatter.numberStyle = NumberFormatter.Style.spellOut
        guard let number = formatter.number(from: str.lowercased()) else {return nil}
        return CGFloat(truncating: number)
    }
    
    
    
    
    
}
