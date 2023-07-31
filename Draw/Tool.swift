//
//  Tool.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 19/05/23.
//

import UIKit

enum ToolType{
    case Pen
    case EraserVec
    case EraserBit
    case Marker
    case Lasso
}

protocol Tool{
    var type: ToolType{
        get
        set
    }
    
    var width: Float{
        get
        set
    }
    
    var color: UIColor{
        get
        set
    }
}

class Pen: Tool{
    
    var type: ToolType
    var width: Float
    var color: UIColor
    
    init(width: Float, color: UIColor){
        self.type = .Pen
        self.width = width
        self.color = color
    }
    
}

class EraserVec: Tool{
    
    var type: ToolType
    var width: Float
    var color: UIColor
    
    init(width: Float){
        self.type = .EraserVec
        self.width = width
        self.color = .white
    }
    
    func erase(eraseLine: Stroke, eraseFrom drawing: Drawing) -> Drawing{
        for stroke in drawing.strokes{
            if eraseLine.path.cgPath.intersects(stroke.path.cgPath){
                drawing.removeStrokeByUUID(stroke.UUID)
            }
        }
        
        return drawing
    }
}

class EraserBit: Tool{
    
    var type: ToolType
    var width: Float
    var color: UIColor
    var isErasing = false
    
    init(width: Float){
        self.type = .EraserBit
        self.width = width
        self.color = .white
    }
    
    func erase(eraseLine: Stroke, eraseFrom drawing: Drawing) -> Drawing{
        var point = CGPoint()
        for stroke in drawing.strokes{
            if eraseLine.path.cgPath.intersects(stroke.path.cgPath) {
                self.isErasing = true
                var min = cgDistance(point1: stroke.pointsTo[0], point2: eraseLine.path.cgPath.currentPoint)
                
                
                for currentP in stroke.pointsMove{
                    let transformedCurrentP = currentP.applying(stroke.transform)
                    let distance = cgDistance(point1: transformedCurrentP, point2: eraseLine.path.cgPath.currentPoint)
                    if distance < min{
                        min = distance
                        point = currentP
                    }
                    
                    
                    
                }
                print("intersect at: \(point)")
                
                
                if point != CGPoint(x: 0, y: 0){
                    let newStroke = newStrokes(erasedStroke: stroke, breakPoint: point)
                    drawing.append(newStroke)
                    
                    drawing.removeStrokeByUUID(stroke.UUID)
                    
                    let eraserLayer = CAShapeLayer()
                    eraserLayer.path = eraseLine.path.cgPath
                    
                }
            }
        }

        return drawing
    }
    
    func newStrokes(erasedStroke: Stroke, breakPoint: CGPoint) -> Array<Stroke>{
        //var newStrokes: Stroke
        
        var firstPointsMove: [CGPoint] = []
        var firstPointsTo: [CGPoint] = []
        var firstControlPoints: [CGPoint] = []
        
        var secondPointsMove: [CGPoint] = []
        var secondPointsTo: [CGPoint] = []
        var secondControlPoints: [CGPoint] = []
        
        var isFirst = true
        
        for i in 0..<erasedStroke.pointsMove.count-1{
            if erasedStroke.pointsMove[i] != breakPoint && isFirst{
                firstPointsMove.append(erasedStroke.pointsMove[i])
                firstPointsTo.append(erasedStroke.pointsTo[i])
                firstControlPoints.append(erasedStroke.controlPoints[i])
            }
            
            else if erasedStroke.pointsMove[i] == breakPoint{
                firstPointsMove.append(erasedStroke.pointsMove[i])
//                firstPointsTo.append(erasedStroke.pointsTo[i])
//                firstControlPoints.append(erasedStroke.controlPoints[i])
                isFirst = false
            }
            
            else if erasedStroke.pointsMove[i] != breakPoint && !isFirst{
                secondPointsMove.append(erasedStroke.pointsMove[i])
                secondPointsTo.append(erasedStroke.pointsTo[i])
                secondControlPoints.append(erasedStroke.controlPoints[i])
            }
        }
        
        secondPointsMove.append(erasedStroke.pointsMove[erasedStroke.pointsMove.count-1])
        
        if firstPointsMove.count == firstPointsTo.count || firstPointsMove.count == firstControlPoints.count{
            firstPointsTo.remove(at: firstPointsTo.endIndex-1)
            firstControlPoints.remove(at: firstControlPoints.endIndex-1)
        }
        
        if secondPointsMove.count == secondPointsTo.count || secondPointsMove.count == secondControlPoints.count{
            secondPointsTo.remove(at: secondPointsTo.endIndex-1)
            secondControlPoints.remove(at: secondControlPoints.endIndex-1)
        }
        
        
//        print("PointsMove \(erasedStroke.pointsMove)")
//        print("PointsTo \(erasedStroke.pointsTo)")
//        print("ControlPoints \(erasedStroke.controlPoints)")
//        print("pointsMove: \(erasedStroke.pointsMove.count), pointsTo: \(erasedStroke.pointsTo.count), controlPoints: \(erasedStroke.controlPoints.count)")
//        print("")
//        print("PointsMove1 \(firstPointsMove)")
//        print("PointsTo1 \(firstPointsTo)")
//        print("ControlPoints1 \(firstControlPoints)")
//        print("pointsMove1: \(firstPointsMove.count), pointsTo1: \(firstPointsTo.count), controlPoints1: \(firstControlPoints.count)")
//        print("")
//        print("PointsMove2 \(secondPointsMove)")
//        print("PointsTo2 \(secondPointsTo)")
//        print("ControlPoints2 \(secondControlPoints)")
//        print("pointsMove2: \(secondPointsMove.count), pointsTo2: \(secondPointsTo.count), controlPoints2: \(secondControlPoints.count)")
//        print("")
//        print("")
//        print("")
       
        var strokes : Array<Stroke> = []
        
        if firstPointsMove.count > 1 && firstPointsTo.count > 1 && firstControlPoints.count > 1 {
            let firstStroke = Stroke(pointsMove: firstPointsMove, pointsTo: firstPointsTo, controlPoints: firstControlPoints, lineWidth: erasedStroke.path.lineWidth, color: erasedStroke.color, transform: erasedStroke.transform)
            strokes.append(firstStroke)
        }
        
        if secondPointsMove.count > 1 && secondPointsTo.count > 1 && secondControlPoints.count > 1 {
            let secondStroke = Stroke(pointsMove: secondPointsMove, pointsTo: secondPointsTo, controlPoints: secondControlPoints, lineWidth: erasedStroke.path.lineWidth, color: erasedStroke.color, transform: erasedStroke.transform)
            strokes.append(secondStroke)
        }
        
        return strokes
    }
    
}

class Lasso: Tool{
    var type: ToolType
    var width: Float
    var color: UIColor
    
    init(){
        self.type = .Lasso
        self.width = 3
        self.color = .systemBlue
    }
    
    func determineSelectedPaths(lassoStroke: Stroke, selectFrom drawing: Drawing) -> Drawing{
        for stroke in drawing.strokes{
            for point in stroke.pointsMove{
                if lassoStroke.path.contains(point) && lassoStroke.path.bounds.contains(point){
                    
                    print(stroke.UUID)
                    let selectedStroke = selectStroke(stroke)
                    drawing.append([selectedStroke])
                    drawing.removeStrokeByUUID(stroke.UUID)
                }
                    
            }
        }
        
        return drawing
    }
    
    func selectStroke(_ stroke : Stroke) -> Stroke{
        let newStroke = Stroke(path: stroke.path, color: .red)
        
        return newStroke
    }
    
}


