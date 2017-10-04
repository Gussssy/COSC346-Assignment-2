//
//  AppDelegate.swift
//  PDFviewer
//
//  Created by Tristan Gardner and maybe Angus 9/28/17.
//  Copyright © 2017 Tristan Gardner. All rights reserved.
//

import Cocoa
import Quartz


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, TimerModelDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let url = NSURL.fileURL(withPath: Bundle.main.path(forResource: "Lecture1", ofType: "pdf")!)
        //let url = NSURL.fileURL(withPath: "/home/cshome/t/trgardner/COSC346-Assignment-2/Lecture1.pdf")
        let pdf = PDFDocument(url: url)
        screen.allowsDragging = true
        screen.document = pdf
        pdfModel = PDFModel()
        document = pdf
        pdfModel!.lectureArray = ["Lecture1","Lecture2", "Lecture3"]
        previousLectureButton.isEnabled = false
        populateLecturePullDown(list: pdfModel!.lectureArray)
        
        //Timer Stuff
        lectureTimer = LectureTimerModel()
        lectureTimer!.delegate = self
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var screen: PDFView!
    

    @IBOutlet weak var nextPageButton: NSButton!

    @IBOutlet weak var lastPageButton: NSButton!

    @IBOutlet weak var nextLectureButton: NSButton!
    
    @IBOutlet weak var previousLectureButton: NSButton!

    //instance variable
    
    var document: PDFDocument?
    
    var pdfModel: PDFModel?
    
    var lectureTimer : LectureTimerModel?
    
    func populateLecturePullDown(list: Array<String>){
        var i = 0
        while i < list.count{
            lectureMenuPullDown.addItem(withTitle: list[i])
            i += 1
        }
    }
    
    @IBAction func nextPage(_ sender: Any) {
        pdfModel!.next(screen: screen)
        pageNum += 1
        changePageDisplay(_ : (Any).self)
    }
    
    @IBAction func previousPage(_ sender: Any) {
        pdfModel!.previous(screen: screen)
        pageNum += -1
        changePageDisplay(_ : (Any).self)

    }
    
    @IBOutlet weak var pageNumberEntry: NSTextField!
    @IBOutlet weak var jumpButton: NSButton!
    
    @IBAction func jumpToPage(_ sender: Any) {
        document = screen.document
        let num = Int(pageNumberEntry.stringValue)
        if  num! <= (document!.pageCount){
            pdfModel!.jump(screen: screen, num: num!)
            pageNum = num!
            changePageDisplay(_ : (Any).self)
        }
    }
    
    var lectureNum = 1
    
    @IBAction func nextLecture(_ sender: Any) {
        lectureNum += 1
        lectureLabel.stringValue = "lecture \(lectureNum)"
        pageNum = 1
        changePageDisplay(_: (Any).self)
        previousLectureButton.isEnabled = true
        let disable = pdfModel!.nextLecture(screen: screen)
        bookmarkPullDown.removeAllItems()
        if disable {
            nextLectureButton.isEnabled = false
        }
    }
    
    @IBAction func previousLecture(_ sender: Any) {
        lectureNum += -1
        lectureLabel.stringValue = "lecture \(lectureNum)"
        pageNum = 1
        changePageDisplay(_: (Any).self)
        nextLectureButton.isEnabled = true
        let disable = pdfModel!.previousLecture(screen: screen)
        bookmarkPullDown.removeAllItems()
        if disable{
            previousLectureButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var lectureMenuPullDown: NSPopUpButton!
    
    @IBAction func skipToLecture(_ sender: Any) {
        let lecture = lectureMenuPullDown.selectedItem?.title
        pdfModel!.skipToLecture(screen: screen, lecture: lecture!)
        if lecture == lectureMenuPullDown.lastItem?.title{
            previousLectureButton.isEnabled = true
            nextLectureButton.isEnabled = false
        }
        if lecture == lectureMenuPullDown.item(at: 1)?.title{
            previousLectureButton.isEnabled = false
            nextLectureButton.isEnabled = true
        }
    }
    
    @IBOutlet weak var lectureLabel: NSTextField!
    
    @IBOutlet weak var pageLabel: NSTextField!
    var pageNum = 1
    
    @IBOutlet var zoomInButton: NSButton!
    @IBAction func zoomIn(sender: AnyObject) {
        pdfModel!.zoomIn(screen: screen)
    }
    
    @IBOutlet var zoomOutButton: NSButton!
    @IBAction func zoomOut(sender: AnyObject) {
        pdfModel!.zoomOut(screen: screen)
    }
    

    
    
    @IBOutlet weak var annotation: NSTextField!
    
    @IBAction func annotate(_ sender: Any) {
        if pdfModel != nil{
            if let page = screen.currentPage{
                let words = String(annotation.stringValue)
                pdfModel!.annotate(page: page, comment: words!)
                annotation.stringValue = ""
            }
        }
        
    }
    
    @IBAction func readAnnotation(_ sender: Any) {
        let note = pdfModel!.readAnnoations(screen: screen)
        annotation.stringValue = note
    }
    
    @IBAction func annotateLecture(_ sender: Any) {
        let comment = annotation.stringValue
        pdfModel!.annotateLecture(screen: screen, comment: comment)
        annotation.stringValue = ""
    }
    
    
    @IBAction func readLectureNotes(_ sender: Any) {
        let notes = pdfModel!.readLectureNotes(screen: screen)
        annotation.stringValue = notes
    }
    
    var bookmarkNum = 1
    @IBAction func bookmarkPage(_ sender: Any) {
        if let page = screen.currentPage{
            pdfModel!.bookmarkPage(page: page)
        }
        bookmarkPullDown.addItem(withTitle: "\(bookmarkNum)")
        bookmarkNum += 1
    }
    
    
    @IBOutlet weak var bookmarkPullDown: NSPopUpButton!
    
    @IBAction func skipToMark(_ sender: Any) {
        let mark = bookmarkPullDown.selectedItem?.title
        if mark == "Bookmarks"{return}
        pdfModel!.bookmarkSkip(screen: screen, mark: Int(mark!)!)
    }
    
    
    @IBAction func changePageDisplay(_ sender: Any) {
        pageLabel.stringValue = "page" + String(pageNum)
    }
    
    
    @IBAction func search(_ sender: Any) {
        let resultsNum = pdfModel!.find(screen: screen, term: annotation.stringValue)
        annotation.stringValue = "\(resultsNum) result(s)"
    }
    
    @IBOutlet weak var nextResultButton: NSButton!
    @IBAction func nextSearchResult(_ sender: Any) {
        pdfModel!.nextSearchResult(screen: screen)
    }
    /////////////////////////////////////////////////////////
    //                  TIMER STUFF                        //
    /////////////////////////////////////////////////////////
    
    
    
    
    // Timer IB stff
    @IBOutlet weak var timeElaspsed: NSTextField!
    @IBOutlet weak var startTimer: NSButton!
    @IBOutlet weak var resetTimer: NSButton!
    
    
    
    @IBAction func startTimer(_ sender: Any) {
        
        if (startTimer.title == "Start"){
            lectureTimer!.start()
            startTimer.title = "Pause"
        }else{
            lectureTimer!.stop()
            startTimer.title = "Start"
        }
        
    }
    
    @IBAction func resetTimer(_ sender: Any) {
        //lectureTimer!.stop()
        lectureTimer!.reset()
    }
    
    
    
    // Update the label to show the current time, formatted for display
    // callback target from TimerModel
    func secondsChanged(_ seconds: Int) {
        // Take the total number of seconds the timer has run for
        var s = seconds
        // Determine how many hours and minutes this represents
        let h = s/3600
        s %= 3600
        let m = s/60
        s %= 60
        
        // Update the label with the formatted timer value
        // (Rather ObjCly!)
        timeElaspsed.stringValue = String(format:"%02ld:%02ld:%02ld", h,m,s)
        //checkTime()
    }

    
}

