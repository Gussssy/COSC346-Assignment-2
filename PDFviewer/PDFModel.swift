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
    var lectureNotes = Dictionary<PDFDocument, String>()
    var searchResults = Array<PDFSelection>()
    var currentResult: Int = 0
    var titleToDocumentDict = Dictionary<PDFDocument, String>()
    
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
        let doc = screen.document
        if let message = lectureNotes[doc!]{
            lectureNotes[doc!] = message + " \(comment)"
        }
        else{
            lectureNotes[doc!] = comment
        }
    }
    
    //bring up notes about the lecture
    func readLectureNotes(screen: PDFView) -> String{
        let doc = screen.document
        if let notes = lectureNotes[doc!]{
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
    
    
    
    /////////////////////////////////////////////////////////
    //                 Annotation Storage                  //
    /////////////////////////////////////////////////////////
    
    
    // FUNCTION:  Stores annotation assocated with a particular page and lecture
    func storeLectureAnnotation(screen : PDFView, annotation : String){
        
        //Create a file named after the Lecture Name and Page number
        let lectureName : String = titleToDocumentDict[screen.document!]!
        let fileName : String =  lectureName
        let file = fileName
        
        //Create or accesss exisiting file and store text by overwriting anything prexisting
        if let dir = FileManager.default.urls(for: .applicationDirectory, in: .userDomainMask).first{
            
            //the files url
            let fileURL = dir.appendingPathComponent(file)
            
            do {
                
                try annotation.write(to: fileURL, atomically: false, encoding: .utf8)
                print("Saving to: \(fileURL)")
                
            } catch{print("Error")}
            
        }
        
        
    }//end of function
    
    
    func storePageAnnotation(screen : PDFView, annotation : String){
        //Create a file named after the Lecture Name and Page number
        
        if screen.document == nil {return}
        let pageNum : Int = (screen.document?.index(for : screen.currentPage!))! + 1
        let lectureName : String = titleToDocumentDict[screen.document!]!
        let fileName : String =  lectureName + " Page " + String(pageNum)
        let file = fileName
        
        //What does this really do
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            //the files url
            let fileURL = dir.appendingPathComponent(file)
            
            do {
                
                try annotation.write(to: fileURL, atomically: false, encoding: .utf8)
                print("Saving to: \(fileURL)")
                
            } catch{print("Error")}
            
        }
        
        
    }//end of function
    
    
    //FUNC: readLectureAnnotation
    //  Reads Lecture annotation from text file if present
    //  returns the text file contents or empty string
    func readLectureAnnotation(screen : PDFView)-> String{
        
        // To store the read string
        var readText : String = ""
        
        
        //Determine file name to be read from the current page
        let lectureName : String = titleToDocumentDict[screen.document!]!
        let fileName : String =  lectureName
        let file = fileName
        
        //What does this really do
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            //the files url
            let fileURL = dir.appendingPathComponent(file)
            
            // Attempt to read from file
            do {
                
                readText = try String(contentsOf: fileURL, encoding: .utf8)
                print("I have read text from file: \(read) ")
                
            } catch{print("No Annotation Found")}
            
            //No text file was found, return empty string
            return readText
        }
        //Text file was found, returns the contents
        return readText
        
    }//end of function
    
    
    func readPageAnnotation(screen : PDFView) -> String{
        
        // To store the read string
        var readText : String = ""
        
        
        //Determine file name to be read from the current page
        let lectureName : String = titleToDocumentDict[screen.document!]!
        let pageNum : Int = (screen.document?.index(for : screen.currentPage!))! + 1
        let fileName : String =  lectureName + " Page " + String(pageNum)
        let file = fileName
        
        //What does this really do
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            
            //the files url
            let fileURL = dir.appendingPathComponent(file)
            
            // Attempt to read from file
            do {
                
                readText = try String(contentsOf: fileURL, encoding: .utf8)
                print("I have read text from file: \(read) ")
                
            } catch{print("No Annotation Found")}
            
            //
            return readText
        }
        
        return readText
    }
    

    
    
}
