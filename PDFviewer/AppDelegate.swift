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
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //let url = NSURL.fileURL(withPath: "http://www.cs.otago.ac.nz/cosc346/Lectures/Lecture1.pdf")
        //let pdf = PDFDocument(url: url)
        screen.allowsDragging = true
        //screen.document = pdf
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var screen: PDFView!
    
    @IBOutlet weak var thumbnail: PDFThumbnailView!

    @IBOutlet weak var nextPageButton: NSButton!

    @IBOutlet weak var lastPageButton: NSButton!

    @IBOutlet weak var nextLectureButton: NSButton!
    
    @IBOutlet weak var lastLectureButton: NSButton!
    
    var document: PDFDocument?
    
    @IBAction func nextPage(_ sender: Any) {
        if screen.canGoToNextPage(){
            screen.goToNextPage(_ : Any)
            pageNum += 1
            changePageDisplay(_ : (Any).self)
        }
    }
    
    @IBAction func previousPage(_ sender: Any) {
        if screen.canGoToPreviousPage(){
            screen.goToPreviousPage(_ : Any)
            pageNum += -1
            changePageDisplay(_ : (Any).self)
        }

    }
    
    @IBOutlet weak var pageNumberEntry: NSTextField!
    @IBOutlet weak var jumpButton: NSButton!
    
    @IBAction func jumpToPage(_ sender: Any) {
        document = screen.document
        print(pageNumberEntry.stringValue)
        let num = Int(pageNumberEntry.stringValue)
        if  num! <= (document!.pageCount){
            //screen.go(to: document!.page(at: num!)!)
            screen.goToFirstPage(_ : Any)
            pageNum = num!
            var i = 0
            while i < num!{
                print(i)
                screen.goToNextPage(_: (Any).self)
                i+=1
            }
            changePageDisplay(_ : (Any).self)
        }
    }
    
    
    @IBOutlet weak var lectureLabel: NSTextField!
    
    @IBOutlet weak var pageLabel: NSTextField!
    var pageNum = 1
    
    
    @IBAction func changePageDisplay(_ sender: Any) {
        pageLabel.stringValue = "page" + String(pageNum)
    }
}

