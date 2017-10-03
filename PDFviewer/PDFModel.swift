//
//  PDFModel.swift
//  PDFviewer
//
//  Created by Tristan Gardner on 10/1/17.
//  Copyright © 2017 Tristan Gardner. All rights reserved.
//

import Foundation
import Quartz

public protocol PDFModelDelegate{
    func nextPage(_ sender: Any)
    func previousPage(_ sender: Any)
    func jumpToPage(_ sender: Any)
}

public class PDFModel{
    
    var bookmarks: Array<PDFPage> = Array()
    var currentMark: Int = 0
    var annotationsDict = Dictionary<PDFPage, String>()
    var lectureArray = Array<String>()
    var currentLecture: Int = 0
    var lectureNotes = Dictionary<PDFDocument, String>()
    
    func next(screen: PDFView){
        if screen.canGoToNextPage(){
            screen.goToNextPage(_ : (Any).self)
            //pageNum += 1
            //changePageDisplay(_ : (Any).self)
            }
        }
    
    func previous(screen: PDFView){
        if screen.canGoToPreviousPage(){
            screen.goToPreviousPage(_ : (Any).self)
        }
    }
    
    func jump(screen: PDFView, num: Int){
        screen.goToFirstPage(_ : (Any).self)
        var i = 1
        while i < num{
            screen.goToNextPage(_: (Any).self)
            i+=1
        }
    }
    
    // return True if the nextLecture button should be disabled
    func nextLecture(screen: PDFView) -> Bool{
        if currentLecture >= lectureArray.count - 1{
            return true
        }
        currentLecture += 1
        let lecture = lectureArray[currentLecture]
        let url = NSURL.fileURL(withPath: Bundle.main.path(forResource: lecture, ofType: "pdf")!)
        let pdf = PDFDocument(url: url)
        screen.document = pdf
        if currentLecture == lectureArray.count - 1{
            return true
        }
        return false
    }
    
    // return True if the previousLecture button should be disabled
    func previousLecture(screen: PDFView) -> Bool{
        if currentLecture <= 0{
            return true
        }
        currentLecture += -1
        let lecture = lectureArray[currentLecture]
        let url = NSURL.fileURL(withPath: Bundle.main.path(forResource: lecture, ofType: "pdf")!)
        let pdf = PDFDocument(url: url)
        screen.document = pdf
        if currentLecture == 0{
            return true
        }
        return false
    }
    
    func zoomIn(screen: PDFView){
        if screen.canZoomIn(){
            screen.zoomIn(_: (Any).self)
        }
    }
    
    func zoomOut(screen: PDFView){
        if screen.canZoomOut(){
            screen.zoomOut(_: (Any).self)
        }
    }
    
    func annotate(page: PDFPage, comment: String){
        if let messages = annotationsDict[page]{
            annotationsDict[page] = messages + " \(comment)"
        }
        else{
            annotationsDict[page] = comment
        }
    }
    
    func readAnnoations(screen: PDFView) -> String{
        let page = screen.currentPage
        if let annotation = annotationsDict[page!]{
            return annotation
        }
        return ""
    }
    
    func annotateLecture(screen: PDFView, comment: String){
        let doc = screen.document
        if let message = lectureNotes[doc!]{
            lectureNotes[doc!] = message + " \(comment)"
        }
        else{
            lectureNotes[doc!] = comment
        }
    }
    
    func readLectureNotes(screen: PDFView) -> String{
        print("here")
        let doc = screen.document
        print("1 + \(lectureNotes[doc!])")
        if let notes = lectureNotes[doc!]{
            print(notes)
            return notes
        }
        return ""
    }
    
    func bookmarkPage(page: PDFPage){
        bookmarks.append(page)
    }
    
    func bookmarkSkip(screen: PDFView, mark: Int){
        if !bookmarks.isEmpty{
            screen.go(to: bookmarks[mark-1])
        }
    }
}
