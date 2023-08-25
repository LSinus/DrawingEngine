//
//  Shape.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 17/05/23.
//
import UIKit

class Rect: Stroke{
    func edit(){
        
    }
}

class Line: Stroke{
    var startPoint: CGPoint
    var endPoint: CGPoint
    private var linePath: UIBezierPath = UIBezierPath()
    
    init(startPoint: CGPoint, endPoint: CGPoint, color: UIColor) {
        self.startPoint = startPoint
        self.endPoint = endPoint
        
        let distance = cgDistance(point1: startPoint, point2: endPoint)
        let numberOfIntermediatePoints = Int(distance / 10)
        
        let deltaX = (endPoint.x - startPoint.x) / CGFloat(numberOfIntermediatePoints + 1)
        let deltaY = (endPoint.y - startPoint.y) / CGFloat(numberOfIntermediatePoints + 1)
        
        linePath.move(to: startPoint)
        
        for i in 1...numberOfIntermediatePoints {
            let intermediatePoint = CGPoint(x: startPoint.x + CGFloat(i) * deltaX, y: startPoint.y + CGFloat(i) * deltaY)
            linePath.addLine(to: intermediatePoint)
            linePath.move(to: intermediatePoint)
            
        }
        
        linePath.addLine(to: endPoint)
        
        super.init(path: linePath, color: color)
    }
}

class Circle: Stroke{
    func edit(){
        
    }
}
