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
        document = screen.document
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
        }
    }
    
    @IBAction func previousPage(_ sender: Any) {
        if screen.canGoToPreviousPage(){
            screen.goToPreviousPage(_ : Any)
        }

    }
    
    @IBOutlet weak var pageNumberEntry: NSTextField!
    @IBOutlet weak var jumpButton: NSButton!
    
    @IBAction func jumpToPage(_ sender: Any) {
        let num = Int(pageNumberEntry.imageTitle())
        if  num! >= (document!.pageCount){
            screen.go(to: document!.page(at: num!)!)
        }
    }
    
    
}

