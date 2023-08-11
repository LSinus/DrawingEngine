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
    
    func copy() -> Tool
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
    
    func copy() -> Tool {
        return Pen(width: self.width, color: self.color)
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
    
    func erase(eraseLine: Stroke, eraseFrom drawing: Drawing){
        for stroke in drawing.strokes{
            if eraseLine.path.cgPath.intersects(stroke.path.cgPath){
                drawing.removeStrokeByUUID(stroke.UUID)
            }
        }
    }
    
    func copy() -> Tool {
        return EraserVec(width: self.width)
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
    
    func erase(eraseLine: Stroke, eraseFrom drawing: Drawing){
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
                if point != CGPoint(x: 0, y: 0){
                    let newStroke = newStrokes(erasedStroke: stroke, breakPoint: point)
                    drawing.append(newStroke)
                    drawing.removeStrokeByUUID(stroke.UUID)
                    let eraserLayer = CAShapeLayer()
                    eraserLayer.path = eraseLine.path.cgPath
                }
            }
        }
    }
    
    func newStrokes(erasedStroke: Stroke, breakPoint: CGPoint) -> Array<Stroke>{
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
    
    func copy() -> Tool {
        return EraserBit(width: self.width)
    }
    
}

class Marker: Tool{
    var type: ToolType
    var width: Float
    var color: UIColor
    var markedStrokes: [Stroke] = []
    
    init(width: Float, color: UIColor){
        self.type = .Marker
        self.width = width
        self.color = color.withAlphaComponent(0.5)
    }
    
    init(width: Float, color: UIColor, markedStrokes: [Stroke]){
        self.type = .Marker
        self.width = width
        self.color = color.withAlphaComponent(0.5)
        self.markedStrokes = markedStrokes
    }
    
    private func getMarkedStrokes(_ markerStroke: Stroke, _ drawing: Drawing){
        for stroke in drawing.strokes{
            for point in stroke.pointsMove{
                if markerStroke.path.contains(point.applying(stroke.transform)) && markerStroke.path.bounds.contains(point.applying(stroke.transform)) || markerStroke.path.cgPath.intersects(stroke.path.cgPath){
                    markedStrokes.append(stroke)
                    break
                }
            }
        }
    }
    
    private func insertBeforeMarked(_ markerStroke: Stroke, _ drawing: Drawing){
        for (i, stroke) in drawing.strokes.enumerated(){
            for markedStroke in markedStrokes{
                if markedStroke.UUID == stroke.UUID{
                    drawing.strokes.insert(markerStroke, at: i)
                    markedStrokes = []
                    return
                }
            }
        }
        
        drawing.append(markerStroke)
        
    }
    
    func Mark(markerStroke: Stroke, markFrom drawing: Drawing){
        getMarkedStrokes(markerStroke, drawing)
        insertBeforeMarked(markerStroke, drawing)
    }
    
    func copy() -> Tool {
        return Marker(width: self.width, color: self.color, markedStrokes: self.markedStrokes)
    }
}

class Lasso: Tool{
    var type: ToolType
    var width: Float
    var color: UIColor
    var selectedStrokes: [Stroke]
    var stroke: Stroke
    var isTranslating = false
    var dash = 10.0
    var space = 10.0
    
    init(){
        self.type = .Lasso
        self.width = 3
        self.color = .systemBlue
        self.selectedStrokes = []
        self.stroke = Stroke()
    }
    
    init(stroke: Stroke, seletedStrokes: [Stroke], isTraslating: Bool){
        self.type = .Lasso
        self.width = 3
        self.color = .systemBlue
        self.stroke = stroke
        self.selectedStrokes = seletedStrokes
        self.isTranslating = isTraslating
    }
    
    func determineSelectedPaths(lassoStroke: Stroke, selectFrom drawing: Drawing) -> Int{
        isTranslating = true
        var numberOfSelectedStrokes = 0
        for stroke in drawing.strokes{
            if !stroke.isLasso{
                for point in stroke.pointsMove{
                    if lassoStroke.path.contains(point.applying(stroke.transform)) && lassoStroke.path.bounds.contains(point.applying(stroke.transform)){
                        numberOfSelectedStrokes += 1
                        self.selectedStrokes.append(stroke)
                        self.stroke = lassoStroke
                        SelectionMenuView.selectionMenu.setMenuOptions(options: SelectionMenuView.selectionMenu.standardOptions)
                        break
                    }
                    
                }
            }
        }
        
        return numberOfSelectedStrokes
    }
    
    func selectStroke(_ stroke : Stroke) -> Stroke{
        let newStroke = Stroke(path: stroke.path, color: .red)
        
        return newStroke
    }
    
    func checkTraslation(position: CGPoint){
        if stroke.path.contains(position) && stroke.path.bounds.contains(position){
            isTranslating = true
            return
        }
        if SelectionMenuView.selectionMenu.copy.count > 0 && SelectionMenuView.selectionMenu.menuOptions == SelectionMenuView.selectionMenu.pasteOptions{
            SelectionMenuView.selectionMenu.useMenu(atPoint: position)
            isTranslating = false
            stroke = Stroke()
            return
        }
        isTranslating = false
        selectedStrokes = []
        stroke = Stroke()
        SelectionMenuView.selectionMenu.resetMenu()
    }
    
    func beginTranslatingStroke(position: CGPoint, previousPosition: CGPoint, translateFrom drawing: Drawing){
        if stroke.path.contains(position) && stroke.path.bounds.contains(position){
            
            let deltaX = position.x - previousPosition.x
            let deltaY = position.y - previousPosition.y
            
            let transform = CGAffineTransform(translationX: deltaX, y: deltaY)
            
            stroke.apply(transform)
            
            for selectedStroke in selectedStrokes {
                drawing.translateStroke(UUID: selectedStroke.UUID, translateWith: transform)
                
            }
        }
        
        else{
            isTranslating = false
            selectedStrokes = []
        }
    }
    
    func translateStroke(position: CGPoint, previousPosition: CGPoint, translateFrom drawing: Drawing){
        let deltaX = position.x - previousPosition.x
        let deltaY = position.y - previousPosition.y
        
        let transform = CGAffineTransform(translationX: deltaX, y: deltaY)
        
        stroke.apply(transform)
        
        for selectedStroke in selectedStrokes {
            drawing.translateStroke(UUID: selectedStroke.UUID, translateWith: transform)
            
        }
    }
    
    func calculateDashSize(vel: CGFloat){
        space = 10 * vel
    }
    
    func deleteStroke(removeFrom drawing: Drawing){
        for stroke in selectedStrokes{
            drawing.removeStrokeByUUID(stroke.UUID)
        }
    }
    
    func copy() -> Tool {
        return Lasso(stroke: self.stroke, seletedStrokes: self.selectedStrokes, isTraslating: self.isTranslating)
    }
    
}


