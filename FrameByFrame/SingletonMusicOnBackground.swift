//
//  SingletonMusicOnBackground.swift
//  FrameByFrame
//
//  Created by Pablo Nuñez on 10/05/2019.
//  Copyright © 2019 CFGS La Salle Gracia. All rights reserved.
//


import Foundation
import AVFoundation

class SingletonMusicOnBackground {
    static let sharedInstance = SingletonMusicOnBackground()
    private var player: AVAudioPlayer?
    
    func create(){
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }catch {
//            print("")
        }
        
        if let backgroundURL = Bundle.main.url(forResource: "soundBackground", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: backgroundURL)
                player?.numberOfLoops = Int(-1)
                player?.prepareToPlay()
                player?.play()
                
            } catch {
//                print("")
            }
        }
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.stop()
    }
}

