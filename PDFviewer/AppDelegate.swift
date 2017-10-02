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
class AppDelegate: NSObject, NSApplicationDelegate, PDFModelDelegate {



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
    

    @IBOutlet weak var nextPageButton: NSButton!

    @IBOutlet weak var lastPageButton: NSButton!

    @IBOutlet weak var nextLectureButton: NSButton!
    
    @IBOutlet weak var lastLectureButton: NSButton!
    
    var document: PDFDocument?
    
    let pdf = PDFModel()
    
    @IBAction func nextPage(_ sender: Any) {
        pdf.next(screen: screen)
        pageNum += 1
        changePageDisplay(_ : (Any).self)
    }
    
    @IBAction func previousPage(_ sender: Any) {
        pdf.previous(screen: screen)
        pageNum += -1
        changePageDisplay(_ : (Any).self)

    }
    
    @IBOutlet weak var pageNumberEntry: NSTextField!
    @IBOutlet weak var jumpButton: NSButton!
    
    @IBAction func jumpToPage(_ sender: Any) {
        document = screen.document
        let num = Int(pageNumberEntry.stringValue)
        if  num! <= (document!.pageCount){
            pdf.jump(screen: screen, num: num!)
            pageNum = num!
            changePageDisplay(_ : (Any).self)
        }
    }
    
    
    
    @IBOutlet weak var lectureLabel: NSTextField!
    
    @IBOutlet weak var pageLabel: NSTextField!
    var pageNum = 1
    
    @IBOutlet var zoomInButton: NSButton!
    @IBAction func zoomIn(sender: AnyObject) {
        pdf.zoomIn(screen: screen)
    }
    
    @IBOutlet var zoomOutButton: NSButton!
    @IBAction func zoomOut(sender: AnyObject) {
        pdf.zoomOut(screen: screen)
    }
    @IBOutlet weak var annotion: NSTextField!
    
    @IBAction func annotate(_ sender: Any) {
        
    }
    
    var bookmarkNum = 1
    @IBAction func bookmarkPage(_ sender: Any) {
        if let page = screen.currentPage{
            pdf.bookmarkPage(page: page)
        }
        bookmarkPullDown.addItem(withTitle: "\(bookmarkNum)")
        bookmarkNum += 1
    }
    
    
    @IBOutlet weak var bookmarkPullDown: NSPopUpButton!
    
    @IBAction func skipToMark(_ sender: Any) {
        let mark = bookmarkPullDown.selectedItem?.title
        pdf.bookmarkSkip(screen: screen, mark: Int(mark!)!)
    }
    
    
    @IBAction func changePageDisplay(_ sender: Any) {
        pageLabel.stringValue = "page" + String(pageNum)
    }
    
    
}

