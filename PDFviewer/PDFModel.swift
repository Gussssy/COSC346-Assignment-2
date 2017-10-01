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
        var i = 0
        while i < num{
            print(i)
            screen.goToNextPage(_: (Any).self)
            i+=1
        }
    }
}
