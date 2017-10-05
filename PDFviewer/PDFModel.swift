//
//  PDFModel.swift
//  PDFviewer
//
//  Created by Tristan Gardner on 10/1/17.
//  Copyright © 2017 Tristan Gardner. All rights reserved.
//

import Foundation
import Quartz


public class PDFModel{
    
    // Instance variables
    
    var bookmarks: Array<PDFPage> = Array()
    var currentMark: Int = 0
    var annotationsDict = Dictionary<PDFPage, String>()
    var lectureArray = Array<String>() //Hold file names for all the lectures inteded for use
    var currentLecture: Int = 0
    var lectureNotes = Dictionary<String, String>()
    var searchResults = Array<PDFSelection>()
    var currentResult: Int = 0
    
    //Go to next Page
    func next(screen: PDFView){
        if screen.canGoToNextPage(){
            screen.goToNextPage(_ : (Any).self)
            }
        }
    
    //Go to previous Page
    func previous(screen: PDFView){
        if screen.canGoToPreviousPage(){
            screen.goToPreviousPage(_ : (Any).self)
        }
    }
    
    // Skip to page of given number
    func jump(screen: PDFView, num: Int){
        screen.goToFirstPage(_ : (Any).self)
        var i = 1
        while i < num{
            screen.goToNextPage(_: (Any).self)
            i+=1
        }
    }
    
    // Go to next lecture return true to disable next lecture
    func nextLecture(screen: PDFView) -> Bool{
        if currentLecture >= lectureArray.count - 1{
            return true
        }
        currentLecture += 1
        let lecture = lectureArray[currentLecture]
        
        //create a file path to the lecture
        
        let url = NSURL.fileURL(withPath: Bundle.main.path(forResource: lecture, ofType: "pdf")!)
        let pdf = PDFDocument(url: url)
        screen.document = pdf
        if currentLecture == lectureArray.count - 1{
            return true
        }
        return false
    }
    
    // Go to previous Lecture return True if the previousLecture button should be disabled
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
    
    //Jump to desired lecture - selected by drop down menu
    func skipToLecture(screen: PDFView, lecture: String){
        if lecture == "Lectures"{ return}
        let url = NSURL.fileURL(withPath: Bundle.main.path(forResource: lecture, ofType: "pdf")!)
        let pdf = PDFDocument(url: url)
        screen.document = pdf
        currentLecture = lectureArray.index(of: lecture)!
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
    
    // save annotation of page - currently always adds with no editing supported
    func annotate(page: PDFPage, comment: String){
        if let messages = annotationsDict[page]{
            annotationsDict[page] = messages + " \(comment)"
        }
        else{
            annotationsDict[page] = comment
        }
    }
    
    //brings up annotations - not yet editable
    func readAnnoations(screen: PDFView) -> String{
        let page = screen.currentPage
        if let annotation = annotationsDict[page!]{
            return annotation
        }
        return ""
    }
    
    // add notes about the lecture
    func annotateLecture(screen: PDFView, comment: String){
        let doc = lectureArray[currentLecture]
        if let message = lectureNotes[doc]{
            lectureNotes[doc] = message + " \(comment)"
        }
        else{
            lectureNotes[doc] = comment
        }
    }
    
    //bring up notes about the lecture
    func readLectureNotes(screen: PDFView) -> String{
        let doc = lectureArray[currentLecture]
        if let notes = lectureNotes[doc]{
            print(notes)
            return notes
        }
        return ""
    }
    
    // add page into bookmark array
    func bookmarkPage(page: PDFPage){
        bookmarks.append(page)
    }
    
    // jump to desired bookmarked page - choice is last clicked option in pull down menu
    func bookmarkSkip(screen: PDFView, mark: Int){
        if !bookmarks.isEmpty{
            screen.go(to: bookmarks[mark-1])
        }
    }
    
    //search document - not including annotations - for term in text box
    //generates a list of the selections including the term
    //returns number of times term was found - currently case sensitive
    func find(screen: PDFView, term: String) -> Int{
        let doc = screen.document
        let selections = doc?.findString(term, withOptions: 0) //Options are not explained so we chose option 0
        searchResults = selections!
        if selections != nil && selections!.count > 0{
            screen.go(to: selections![0])
            return selections!.count
        }
        return 0
    }
    
    // step through search selections one by one
    func nextSearchResult(screen: PDFView){
        currentResult += 1
        if currentResult <= searchResults.count-1{
            screen.go(to: searchResults[currentResult])
        }
    }
}
