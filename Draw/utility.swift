//
//  utility.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 27/07/23.
//

import Foundation

func cgDistance(point1: CGPoint, point2: CGPoint) -> CGFloat{
    let x = point1.x - point2.x
    let y = point1.y - point2.y
    
    let dist = sqrt(pow(x, 2) + pow(y, 2))
    
    return dist
}

func getMidPoint(from: CGPoint, to: CGPoint) -> CGPoint{
    return CGPoint(x: (from.x + to.x)/2, y: (from.y + to.y)/2)
}
