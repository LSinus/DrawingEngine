//
//  Drawing.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 19/05/23.
//

import Foundation
import UIKit

class Drawing{
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
    
    func append(_ newElment: Stroke) {
        self.strokes.append(newElment)
    }
    
    func removeStrokeByUUID(_ UUID: String){
        for (i, stroke) in strokes.enumerated(){
            if(stroke.UUID == UUID){
                strokes.remove(at: i)
            }
        }
    }
    
    func removeLassoStrokes(){
        for stroke in self.strokes{
            if stroke.isLasso{
                removeStrokeByUUID(stroke.UUID)
            }
        }
    }
    
    func translateStroke(UUID: String, translateWith transform: CGAffineTransform){
        for stroke in strokes{
            if(stroke.UUID == UUID){
                stroke.apply(transform)
            }
        }
    }
}
