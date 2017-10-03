//
//  LectureTimerModel.swift
//  PDFviewer
//
//  Created by Angus McMillan on 10/3/17.
//  Copyright © 2017 Tristan Gardner. All rights reserved.
//

import Foundation

// classes implement this protocol to receive callbacks from the TimerModel
public protocol TimerModelDelegate {
    func secondsChanged(_ second:Int)
}



public class LectureTimerModel : NSObject {
    
    var seconds:Int = 0
    var stopping:Bool = false
    
    public fileprivate(set) var running:Bool = false
    public var delegate:TimerModelDelegate? = nil
    
    func alertDelegate() {
        // if a delegate isn't defined, do nothing
        delegate?.secondsChanged(seconds)
    }
    
    // the OS's NSTimer will callback here
    func countUp(_ theTimer:Foundation.Timer) {
        if(!stopping) {
            seconds += 1
            alertDelegate()
        } else {
            theTimer.invalidate()
            running = false
            stopping = false
        }
    }
    
    
    
    public func start() {
        if(running) { return }
        
        // Create a timer object that calls the countUp method every second
        let timer = Foundation.Timer(timeInterval: 1, target: self, selector: #selector(LectureTimerModel.countUp(_:)), userInfo: nil, repeats: true)
        
        // Get a reference to the current event loop
        let loop = RunLoop.current
        
        // Attach the above timer to the event loop:
        // it will then actually start firning
        loop.add(timer, forMode: RunLoopMode.commonModes)
        
        // Change our internal state to running
        running = true
    }
    
    
    
    
    public func stop() {
        stopping = true
    }
    
    
    
    
    public func reset() {
        seconds = 0
        alertDelegate()
    }
    
    
    
}//end of class
