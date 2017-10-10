//
//  LectureTimerModel.swift
//  PDFviewer
//
//  Adapted from Lech Szymanski Desgin and David Eyers Swift Implememntation
//
// Provides timer functionality for several feature of the PDFViewr such as the Timer, The time
//  display, auto presentation mode, and regular updates of the navigation labels on the GUI
//
//  Created by Angus McMillan on 10/3/17.
//  Copyright © 2017 Tristan Gardner. All rights reserved.
//

import Foundation

// classes implement this protocol to receive callbacks from the TimerModel
public protocol LectureTimerDelegate {
    func secondsChanged(_ second:Int)
    func updateTimeDisplay(_ time: String)
}



public class LectureTimerModel : NSObject {
    
    //Instance varibales for the LectureTimer presentation
    var secondsElapsed:Int = 0
    var stopping:Bool = false
    public fileprivate(set) var running:Bool = false
    public var delegate:LectureTimerDelegate? = nil
    
   //Instance varible for time updates
    var  minutes : Int = 0
    var hours : Int = 0
    var seconds : Int = 0
    
    
    
    // Function to initialize the time display,
    //returns the current time which will be placed into the time display
    public func initializeTimeDisplay() -> String{
        
        
        let date = Date()
        let calender = Calendar.current
        
        //Accurately determine the current time from the OS
         minutes = calender.component(.minute, from: date)
         hours = calender.component(.hour, from : date)
         seconds = calender.component(.second, from : date)
        
        
        
    
        //Make a timer
        let timer = Foundation.Timer(timeInterval: 1, target: self, selector: #selector(LectureTimerModel.updateTime(_:)), userInfo: nil, repeats: true)
        let loop = RunLoop.current
        
        
        //Attach timer to the event loop so it will start running
        loop.add(timer, forMode : RunLoopMode.commonModes)
    
        return "\(hours):\(minutes):\(seconds)"
        
    }
    
    // Function that updates the time every 60 seconds FIX THIS
    public func updateTime(_ theTimer:Foundation.Timer){
    
        //print("updateTime inside timermodel has been called, seconds: \(seconds)")
       seconds += 1
        if (seconds == 60){
            seconds = 0
            minutes += 1
            if (minutes == 60){
               hours  += 1
                minutes = 0
            }
        }
       
        //Change the text in the time display
         //print("\(hours):\(minutes):\(seconds)")
        let time : String =  String(format:"%02ld:%02ld:%02ld", hours,minutes,seconds)
        delegate?.updateTimeDisplay(time)
        
    }
    
    func alertDelegateTimeDisplay(){
        
        
        
       //time = String(format:"%02ld:%02ld:%02ld", hours,minutes,seconds)
        delegate?.updateTimeDisplay("\(hours):\(minutes):\(seconds)")
    }
    
    
    func alertDelegateTimer() {
        // if a delegate isn't defined, do nothing
        delegate?.secondsChanged(secondsElapsed)
    }
    
    
    
    
    // the OS's NSTimer will callback here
    func countUp(_ theTimer:Foundation.Timer) {
        if(!stopping) {
            secondsElapsed += 1
            alertDelegateTimer()
        } else {
            theTimer.invalidate()
            running = false
            stopping = false
        }
    }
    
    
    // Start the lecture timer
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
    
    
    
    // Stop the Timer
    public func stop() {
        stopping = true
    }
    
    
    
    // Reset the Timer
    public func reset() {
        secondsElapsed = 0
        alertDelegateTimer()
    }
    
    
    
}//end of class
