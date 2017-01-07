//
//  sound.swift
//  TownHunt
//
//  Created by Alvin Lee on 8/3/16.
//  Copyright © 2016 LeeTech. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

var audioPlayer = AVAudioPlayer()

class Sound{
    func playSound(_ soundName: String){
        let sounds = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: sounds)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch{
            print("Error getting the audio file")
    
        }
    }
}
