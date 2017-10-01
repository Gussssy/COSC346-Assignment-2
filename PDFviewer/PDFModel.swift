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
            print(i)
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
    
    func annotate(screen: PDFView, comment: String){
        let page = screen.currentPage
        let annotation = PDFAnnotation()
        annotation.page = page
        page?.addAnnotation(annotation)
    }
}
