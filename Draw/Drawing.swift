//
//  Drawing.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 19/05/23.
//

import Foundation
import UIKit

protocol AbstractDrawing{
    var strokes: [Stroke]{
        get
        set
    }
    func append(_ newElements: [Stroke])
}

class Drawing: AbstractDrawing{
    var strokes: [Stroke]
    
    init(){
        self.strokes = []
    }
    
    init(_ strokes: [Stroke]){
        self.strokes = []
        for stroke in strokes {
            self.strokes.append(stroke)
        }
    }
    
    func append(_ newElments: [Stroke]) {
        for stroke in newElments {
            self.strokes.append(stroke)
        }
    }
    
    func removeStrokeByUUID(_ UUID: String){
        var newStrokes: [Stroke] = []
        
        for i in 0..<strokes.count {
            if(strokes[i].UUID != UUID){
                newStrokes.append(strokes[i])
            }
        }
        
        self.strokes = newStrokes
    }
    
    func removeLassoStrokes(){
        for stroke in self.strokes{
            if stroke.isLasso{
                removeStrokeByUUID(stroke.UUID)
            }
        }
    }
}
