//
//  Stroke.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 19/05/23.
//

import Foundation
import UIKit

class Stroke: Hashable{
    var UUID: String
    var path: UIBezierPath
    var pointsMove: [CGPoint]
    var pointsTo: [CGPoint]
    var controlPoints: [CGPoint]
    var color: UIColor
    var isLasso = false
    var transform = CGAffineTransform(translationX: 0, y: 0)
    
    init(){
        self.path = UIBezierPath()
        self.pointsMove = []
        self.pointsTo = []
        self.controlPoints = []
        self.UUID = NSUUID().uuidString
        self.path.lineWidth = 5
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.color = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    init(path: UIBezierPath){
        self.UUID = NSUUID().uuidString
        self.path = UIBezierPath(cgPath: path.cgPath)
        self.pointsMove = []
        self.pointsTo = []
        self.controlPoints = []
        self.path.lineWidth = 5
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.color = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        getPointFromPath()
        
//        print("PointsMove \(pointsMove)")
//        print("PointsTo \(pointsTo)")
//        print("ControlPoints \(controlPoints)")
//        print("pointsMove: \(pointsMove.count), pointsTo: \(pointsTo.count), controlPoints: \(controlPoints.count)")
    }
    
    init(path: UIBezierPath, color: UIColor){
        self.UUID = NSUUID().uuidString
        self.path = UIBezierPath(cgPath: path.cgPath)
        self.pointsMove = []
        self.pointsTo = []
        self.controlPoints = []
        self.path.lineWidth = 5
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.color = color
        getPointFromPath()
    }
    
    init(path: UIBezierPath, color: UIColor, lineWidth: CGFloat){
        self.UUID = NSUUID().uuidString
        self.path = UIBezierPath(cgPath: path.cgPath)
        self.pointsMove = []
        self.pointsTo = []
        self.controlPoints = []
        self.path.lineWidth = lineWidth
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.color = color
        getPointFromPath()
    }
    
    init(path: UIBezierPath, color: UIColor, transform: CGAffineTransform){
        self.UUID = NSUUID().uuidString
        self.path = UIBezierPath(cgPath: path.cgPath)
        self.pointsMove = []
        self.pointsTo = []
        self.controlPoints = []
        self.path.lineWidth = 5
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.color = color
        self.transform = transform
        getPointFromPath()
    }
    
    
    init(pointsMove: [CGPoint], pointsTo: [CGPoint], controlPoints: [CGPoint], lineWidth: CGFloat, color: UIColor, transform: CGAffineTransform){
        self.path = UIBezierPath()
        self.pointsMove = pointsMove
        self.pointsTo = pointsTo
        self.controlPoints = controlPoints
        self.UUID = NSUUID().uuidString
        self.path.lineWidth = lineWidth
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.color = color
        self.transform = transform
        constructByPoints()
    }
    
    init(pointsMove: [CGPoint], pointsTo: [CGPoint], controlPoints: [CGPoint], lineWidth: CGFloat, color: UIColor){
//        print("costructedbypoints")
        
        self.path = UIBezierPath()
        self.pointsMove = pointsMove
        self.pointsTo = pointsTo
        self.controlPoints = controlPoints
        self.UUID = NSUUID().uuidString
        self.path.lineWidth = lineWidth
        self.path.lineCapStyle = .round
        self.path.lineJoinStyle = .round
        self.color = color
        constructByPoints()
//
//        print(path)
//
//        print("PointsMove \(pointsMove)")
//        print("PointsTo \(pointsTo)")
//        print("ControlPoints \(controlPoints)")
//        print("pointsMove: \(pointsMove.count), pointsTo: \(pointsTo.count), controlPoints: \(controlPoints.count)")
        
    }
    
    static func ==(lhs: Stroke, rhs: Stroke) -> Bool {
        return lhs.UUID == rhs.UUID
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(UUID)
    }
    
    func copy() -> Stroke{
        let copy = Stroke(pointsMove: self.pointsMove, pointsTo: self.pointsTo, controlPoints: self.controlPoints, lineWidth: self.path.lineWidth, color: self.color, transform: self.transform)
        return copy
    }
    
    func draw(){
        color.setStroke()
        self.path.stroke()
    }
    
    func draw(with tool: Tool){
        self.isLasso = false
        self.path.setLineDash([], count: 0, phase: 0.0)
        if let _ = tool as? Lasso{
            self.isLasso = true
            self.path.setLineDash([10, 10], count: 2, phase: 0.0)
        }
        self.path.lineWidth = CGFloat(tool.width)
        self.color = tool.color
        draw()
    }
    
    func apply(_ transfrom: CGAffineTransform){
        self.transform = self.transform.concatenating(transfrom)
        self.path.apply(transfrom)
    }
    
    func constructByPoints(){
        path.move(to: pointsMove[0])
        for i in 0..<pointsTo.count {
            path.move(to: pointsMove[i+1])
            path.addQuadCurve(to: pointsTo[i], controlPoint: controlPoints[i])
        }
        path.apply(self.transform)
    }
    
    func getPointFromPath(){
        let cgPath = path.cgPath
        var tempPointsMove: [CGPoint] = []

        let pathApplier: @convention(block) (UnsafePointer<CGPathElement>) -> Void = { element in
            let points = element.pointee.points
            let type = element.pointee.type
            
            switch type {
            case .moveToPoint:
                
                tempPointsMove.append(points[0])
                
                break
            case .addLineToPoint:
                
                break
            case .addQuadCurveToPoint:
                
                self.controlPoints.append(points[0])
                self.pointsTo.append(points[1])
                
                break
            case .addCurveToPoint:
                
                break
            case .closeSubpath:
                
                break
            @unknown default:
                
                break
            }
        }

        cgPath.apply(info: unsafeBitCast(pathApplier, to: UnsafeMutableRawPointer.self)) { (userInfo, element) in
            let block = unsafeBitCast(userInfo, to: (@convention(block) (UnsafePointer<CGPathElement>) -> Void).self)
            block(element)
        }
        
        if tempPointsMove != [] {
            self.pointsMove.append(tempPointsMove[0])
            
            for point in tempPointsMove{
                self.pointsMove.append(point)
            }
        }

    }
    
}
