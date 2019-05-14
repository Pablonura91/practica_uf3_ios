//
//  Counter.swift
//  FrameByFrame
//
//  Created by Mac de Pol on 14/05/2019.
//  Copyright © 2019 CFGS La Salle Gracia. All rights reserved.
//

import Foundation

class Counter {
    private(set) var value: Int = 0
    
    func increment(){
        value += 1
    }
    
    func reset(){
        value = 0
    }
    
}
