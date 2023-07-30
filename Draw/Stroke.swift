//
//  Stroke.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 19/05/23.
//

import Foundation
import UIKit

protocol AbstractStroke{
    var path: UIBezierPath {
        get
        set
    }
    var color: UIColor{
        get
        set
    }
    func draw()
    
    func draw(with: Tool)
}

class Stroke{
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
        self.path = path
        self.pointsMove = []
        self.pointsTo = []
        self.controlPoints = []
        self.path.lineWidth = 5
        self.color = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        getPointFromPath()
        
//        print("PointsMove \(pointsMove)")
//        print("PointsTo \(pointsTo)")
//        print("ControlPoints \(controlPoints)")
//        print("pointsMove: \(pointsMove.count), pointsTo: \(pointsTo.count), controlPoints: \(controlPoints.count)")
    }
    
    init(path: UIBezierPath, color: UIColor){
        self.UUID = NSUUID().uuidString
        self.path = path
        self.pointsMove = []
        self.pointsTo = []
        self.controlPoints = []
        self.path.lineWidth = 5
        self.color = color
        getPointFromPath()
//
//        print(path)
//
//        print("PointsMove \(pointsMove)")
//        print("PointsTo \(pointsTo)")
//        print("ControlPoints \(controlPoints)")
//        print("pointsMove: \(pointsMove.count), pointsTo: \(pointsTo.count), controlPoints: \(controlPoints.count)")
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
    
    
    func draw(){
        color.setStroke()
        self.path.stroke()
    }
    
    func draw(with tool: Tool){
        if(tool.type == .Lasso){
            self.isLasso = true
            if let _ = tool as? Lasso{
                self.path.setLineDash([5, 2], count: 2, phase: 0.0)
            }
        }
        
        self.path.lineWidth = CGFloat(tool.width)
        self.color = tool.color
        draw()
        
    }
    
    func constructByPoints(){
        path.move(to: pointsMove[0])
        for i in 0..<pointsTo.count {
            path.move(to: pointsMove[i+1])
            path.addQuadCurve(to: pointsTo[i], controlPoint: controlPoints[i])
        }
        print(transform)
        path.apply(self.transform)
    }
    
    func getPointFromPath(){
        // Supponiamo di avere un UIBezierPath chiamato "bezierPath"

        let cgPath = path.cgPath
        var tempPointsMove: [CGPoint] = []

        // Definiamo una chiusura (closure) che verrà chiamata per ogni segmento del percorso
        let pathApplier: @convention(block) (UnsafePointer<CGPathElement>) -> Void = { element in
            let points = element.pointee.points
            let type = element.pointee.type
            
            switch type {
            case .moveToPoint:
                // Punto di partenza del segmento (Move)
                tempPointsMove.append(points[0])
                // Usa "startPoint" come necessario
                break
            case .addLineToPoint:
                // Punto finale del segmento (To)
                // Usa "endPoint" come necessario
                break
            case .addQuadCurveToPoint:
                // Punto di controllo e punto finale del segmento quadratico (To e ControlPoints)
                self.controlPoints.append(points[0])
                self.pointsTo.append(points[1])
                // Usa "controlPoint" e "endPoint" come necessario
                break
            case .addCurveToPoint:
                // Punti di controllo e punto finale del segmento cubico (To e ControlPoints)
                // Usa "controlPoint1", "controlPoint2" e "endPoint" come necessario
                break
            case .closeSubpath:
                // Il percorso è chiuso, potresti voler fare qualcosa con questa informazione
                break
            @unknown default:
                // Gestione di eventuali tipi futuri aggiunti a CGPathElement
                break
            }
        }

        // Applica la chiusura al percorso del UIBezierPath
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