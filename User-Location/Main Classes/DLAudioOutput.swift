//
//  DLAudioOutput.swift
//  Glider Tool
//
//  Created by sonic on 09.01.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//

import AVFoundation

// MARK: - DLAudioOutput
class DLAudioOutput {
    
    // MARK: Public Class Methods
    class func speak(playBeep: Bool, string: String) {
        
        let playBeep = playBeep
        
        if playBeep == true {
            AudioServicesPlayAlertSound(SystemSoundID(1256))
        }
        
        let speechUtterance = AVSpeechUtterance(string: string)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechUtterance.rate = 0.5
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(speechUtterance)
        
    }
    
}
