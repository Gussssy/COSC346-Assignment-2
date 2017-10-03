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
        print(Bundle.main.bundlePath)
        let url2 = NSURL.fileURL(withPath: Bundle.main.path(forResource: "Lecture1", ofType: "pdf")!)
        //let url2 = NSURL.rel
        let url = NSURL.fileURL(withPath: "/home/cshome/t/trgardner/COSC346-Assignment-2/Lecture1.pdf")
        let pdf = PDFDocument(url: url2)
        screen.allowsDragging = true
        screen.document = pdf
        pdfModel = PDFModel()
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
    
    var pdfModel: PDFModel?
    
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
            }
        }
        
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
        pdfModel!.bookmarkSkip(screen: screen, mark: Int(mark!)!)
    }
    
    
    @IBAction func changePageDisplay(_ sender: Any) {
        pageLabel.stringValue = "page" + String(pageNum)
    }
    
    
}

