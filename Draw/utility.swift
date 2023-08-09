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

func calculateCenterOfStroke(stroke: Stroke) -> CGPoint{
    let boundingRect = stroke.path.bounds
    
    let centerX = boundingRect.origin.x + boundingRect.size.width / 2
    let centerY = boundingRect.origin.y + boundingRect.size.height / 2
    
    return CGPoint(x: centerX, y: centerY)
}

func calculateTranslationBetweenPoints(from: CGPoint, to: CGPoint) -> CGAffineTransform{
    let deltaX = to.x - from.x
    let deltaY = to.y - from.y
    
    return CGAffineTransform(translationX: deltaX, y: deltaY)
}
