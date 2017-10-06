//
//  AppDelegate.swift
//  PDFviewer
//
//  Created by Tristan Gardner and maybe Angus 9/28/17.
//  Copyright © 2017 Tristan Gardner. All rights reserved.
//

import Cocoa
import Quartz


//Remove this ??
import Foundation


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, LectureTimerDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        screen.allowsDragging = true
        pdfModel = PDFModel()
        
        
        //Timer Stuff
        lectureTimer = LectureTimerModel()
        lectureTimer!.delegate = self
        
        
        //Set up time display
        setTimeDisplay()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var screen: PDFView!

    @IBOutlet weak var nextLectureButton: NSMenuItem!
    
    @IBOutlet weak var previousLectureButton: NSMenuItem!
    
    //instance variable
    
    var document: PDFDocument? //current document being viewed
    
    var pdfModel: PDFModel?
    
    var lectureTimer : LectureTimerModel?
    
    var slideTimes = Array<Int>() //list of delay times for each slide should presenter decide to auto present
    
    var autoPresent : Bool = false
    
    var pdfArray = [PDFDocument]()
    
    @IBOutlet weak var lectureLabel: NSTextField!
    
    @IBOutlet weak var pageLabel: NSTextField!
    
    var pageNum = 1 // current page , used to update the page label
    var lectureNum : Int = 1 //current lecture indicated here, used to update the label
    
    //Fill Lecture drop down with all the available lectures
    func populateLecturePullDown(list: Array<String>){
        var i = 0
        while i < list.count{
            lectureMenuPullDown.addItem(withTitle: list[i])
            i += 1
        }
    }
    
    
    @IBAction func openLecture(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseFiles = true
        openPanel.runModal()
        let pdfURL = openPanel.urls
        for url in pdfURL{
            if url.absoluteString.hasSuffix("pdf"){
                let doc = PDFDocument(url:url)!
                pdfArray.append(doc)
                screen.document = doc
                let path = url.lastPathComponent
                let end = path.index(path.endIndex, offsetBy: -4)
                pdfModel?.titleToDocumentDict[doc] = path.substring(to: end)
                lectureMenuPullDown.addItem(withTitle: "\(pdfArray.count)")
            }
            
        }
        if screen.document == nil {return}
        document = screen.document
        populateSlideTimes(doc: document!)
    }
    
    // go to next page of document and update current page reference
    @IBAction func nextPage(_ sender: Any) {
        if screen.canGoToNextPage(){
          pageNum += 1
        }
        pdfModel!.next(screen: screen)
        changePageDisplay(_ : (Any).self)
    }
    
    // go to previous page of document and update current page reference
    @IBAction func previousPage(_ sender: Any) {
        if screen.canGoToPreviousPage(){
            pageNum += -1
        }
        pdfModel!.previous(screen: screen)
        changePageDisplay(_ : (Any).self)
    }
    
    @IBOutlet weak var pageNumberEntry: NSTextField!
    @IBOutlet weak var jumpButton: NSButton!
    
    // skip to page indicated by pageNumberEntry if possible
    @IBAction func jumpToPage(_ sender: Any) {
        document = screen.document
        let num = Int(pageNumberEntry.stringValue)
        if  0 < num! && num! <= (document!.pageCount){
            pdfModel!.jump(screen: screen, num: num!)
            pageNum = num!
            changePageDisplay(_ : (Any).self)
        }
    }
    
    
    //go to the next lecture if possible
    //removes all the bookmarks of the last lecture
    //tries to disable next ecture menu item if on last lecture
    @IBAction func nextLecture(_ sender: Any) {
        if lectureNum < pdfArray.count - 1{
            lectureNum += 1
            lectureLabel.stringValue = "Lecture  \(lectureNum + 1)"
            pageNum = 1
            changePageDisplay(_: (Any).self)
        
            screen.document = pdfArray[lectureNum]
            document = screen.document
            bookmarkPullDown.removeAllItems()
            bookmarkNum = 1
            populateSlideTimes(doc: screen.document!)
        }
    }
    
    //go to the previous lecture if possible
    //removes all the bookmarks of the last lecture
    //tries to disable previous menu item if on first lecture
    @IBAction func previousLecture(_ sender: Any) {
        if lectureNum > 0{
            lectureNum += -1
            lectureLabel.stringValue = "Lecture \(lectureNum + 1)"
            pageNum = 1
            changePageDisplay(_: (Any).self)
        
            screen.document = pdfArray[lectureNum]
            document = screen.document
            bookmarkPullDown.removeAllItems()
            bookmarkNum = 1
            populateSlideTimes(doc: screen.document!)
        }
    }
    
    @IBOutlet weak var lectureMenuPullDown: NSPopUpButton!
    
    
    //jump to the lecture indicated by the pull down menu
    //resets the slide delays
    //reset the bookmark pull down menu
    @IBAction func skipToLecture(_ sender: Any) {
        let lectureIndex = lectureMenuPullDown.selectedItem?.title
        if lectureIndex == "Lectures" {return}
        document = pdfArray[Int(lectureIndex!)! - 1]
        screen.document = document
        bookmarkPullDown.removeAllItems()
        populateSlideTimes(doc: screen.document!)
    }
    
    
    
    @IBAction func zoomIn(sender: AnyObject) {
        pdfModel!.zoomIn(screen: screen)
    }
    
    @IBAction func zoomOut(sender: AnyObject) {
        pdfModel!.zoomOut(screen: screen)
    }
    

    
    // general text entry - the long bar at the bottom - used to annotate and search
    @IBOutlet weak var annotation: NSTextField!
    
    //annotate the current page
    @IBAction func annotate(_ sender: Any) {
       
        pdfModel!.storePageAnnotation(screen: screen, annotation: annotation.stringValue)
        
        /* if pdfModel != nil{
            if let page = screen.currentPage{
                let words = String(annotation.stringValue)
                pdfModel!.annotate(page: page, comment: words!)
                annotation.stringValue = ""
            }
        }*/
        
    }
    
    // read the current pages annotations if any into the text entry bar
    @IBAction func readAnnotation(_ sender: Any) {
        
        let read = pdfModel!.readPageAnnotation(screen: screen)
        annotation.stringValue = read
        
        /*let note = pdfModel!.readAnnoations(screen: screen)
        annotation.stringValue = note*/
    }
    
    //adds annotation to lecture
    @IBAction func annotateLecture(_ sender: Any) {
        let comment = annotation.stringValue
        pdfModel!.annotateLecture(screen: screen, comment: comment)
        annotation.stringValue = ""
    }
    
    //brings up lecture annotations
    @IBAction func readLectureNotes(_ sender: Any) {
        let notes = pdfModel!.readLectureNotes(screen: screen)
        annotation.stringValue = notes
    }
    
    
    var bookmarkNum = 1 //int used to increment the value that should be added to the bookmark menu
    
    //Bookmarks the current page - labeled as the bookmarkNum's current value
    //increments bookmarkNum
    @IBAction func bookmarkPage(_ sender: Any) {
        if let page = screen.currentPage{
            pdfModel!.bookmarkPage(page: page)
        }
        bookmarkPullDown.addItem(withTitle: "\(bookmarkNum)")
        bookmarkNum += 1
    }
    
    
    
    @IBOutlet weak var bookmarkPullDown: NSPopUpButton!
    
    //skips to desired bookmark
    //selection based on last item selected from the pull down menu
    @IBAction func skipToMark(_ sender: Any) {
        let mark = bookmarkPullDown.selectedItem?.title
        if mark == "Bookmarks"{return}
        pdfModel!.bookmarkSkip(screen: screen, mark: Int(mark!)!)
    }
    
    //updates the page label
    @IBAction func changePageDisplay(_ sender: Any) {
        pageLabel.stringValue = "Page " + String(pageNum)
    }
    
    //search for a selection containing the search term
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
        // if auto present check to switch slides
        if autoPresent{
            autoUpdateSlide()
        }
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

    
    /////////////////////////////////////////////////////////
    //                 TIME AND DATE DISPLAY               //
    /////////////////////////////////////////////////////////

    
    @IBOutlet weak var timeDisplay: NSTextFieldCell!
 
    private func setTimeDisplay(){
    
        timeDisplay.stringValue = lectureTimer!.initializeTimeDisplay()
        timeDisplay.isEditable = true
        
    }
    
    
    //call back function
    public func updateTimeDisplay(_ time : String){
    
        //print("This function has been called and the time is \(time)")
        timeDisplay.stringValue = time
        
        // this should fix page abel and num if user has scrolled
        updatePageVal()
        
    
    }
    
    /////////////////////////////////////////////////////////
    //                 Auto Present                        //
    /////////////////////////////////////////////////////////
    
    
    var timeTotal = 0 //keeps running total of slide delay times
    
    //switch to next slide if it is time
    //add the next delay into the total if slide is switched
    // is called every second by the timer to check if slide should change
    func autoUpdateSlide(){
        if document == nil{return}
        if lectureTimer!.secondsElapsed >= timeTotal{
            nextPage(_: (Any).self)
            print(slideTimes)
            timeTotal += slideTimes[pageNum - 1]
        }
    }
    
    @IBOutlet weak var slideDelayEntry: NSTextField!
    
    //creates a list of slide delays - default is 10 seconds until manually overridden
    func populateSlideTimes(doc: PDFDocument){
        var i = 0
        //make the list as long as the amount of pages in the document
        while i < doc.pageCount{
            slideTimes.append(10)
            i += 1
        }
    }
    
    //change the delay time of the current slide
    @IBAction func updateSlideDelay(_ sender: Any) {
        slideTimes[pageNum - 1] = Int(slideDelayEntry.intValue)
        //slideTimes[(document?.index(for: screen.currentPage!))!] = Int(slideDelayEntry.intValue)
        //print(slideTimes)
    }
    
    //start the automatic prsentation
    @IBAction func autoPresent(_ sender: Any) {
        resetTimer((Any).self)
        startTimer((Any).self)
        autoPresent = true
        //make sure total is equal to delay time of first slide
        timeTotal = slideTimes[0]
        pageNum = 1
        changePageDisplay((Any).self)
        screen.goToFirstPage(_:(Any).self)
    }
    
    
    
    //set page label and pageNum to correct item
    //updates every second to check if scrolling has changed the page num
    func updatePageVal(){
        if let correctPageNum = document?.index(for: screen.currentPage!){
            //print(document!.page(at:correctPageNum), pageNum, screen.currentPage!)
            if correctPageNum > 400 {return}
            
            pageNum = correctPageNum + 1
            changePageDisplay(_:(Any).self)
        }
    }
    
}

