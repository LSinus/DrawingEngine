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
    
    case Inspector
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

class Inspector: Tool{
    var type: ToolType
    var width: Float
    var color: UIColor
    
    init(){
        self.type = .Inspector
        self.width = 10
        self.color = .clear
    }
    
    func copy() -> Tool {
        return Inspector()
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
    
    private var state: LassoState
    
    init(_ state: LassoState){
        self.type = .Lasso
        self.width = 3
        self.color = .systemBlue
        self.selectedStrokes = []
        self.stroke = Stroke()
        self.state = state
        transitionTo(state: state)
    }
    
    init(stroke: Stroke, seletedStrokes: [Stroke], state: LassoState){
        self.type = .Lasso
        self.width = 3
        self.color = .systemBlue
        self.stroke = stroke
        self.selectedStrokes = seletedStrokes
        self.state = state
        transitionTo(state: state)
    }
    
    func transitionTo(state: LassoState){
        self.state = state
        self.state.update(context: self)
    }
    
    func beginDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){
        state.beginDrawing(by: canvasViewDelegate, with: touch, in: canvasView)
    }
    
    func continueDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){
        state.continueDrawing(by: canvasViewDelegate, with: touch, in: canvasView)
    }
    
    func finishDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){
        state.finishDrawing(by: canvasViewDelegate, with: touch, in: canvasView)
    }
    

    func determineSelectedPaths(lassoStroke: Stroke, selectFrom drawing: Drawing){
        state.determineSelectedPaths(lassoStroke: lassoStroke, selectFrom: drawing)
    }
    
    func checkState(position: CGPoint, canvasView: CanvasView){
        state.checkState(position: position, canvasView: canvasView)
    }
    
    func translateStroke(position: CGPoint, previousPosition: CGPoint, translateFrom drawing: Drawing){
        state.translateStroke(position: position, previousPosition: previousPosition, translateFrom: drawing)
    }
    
    func deleteStroke(removeFrom drawing: Drawing){
        for stroke in selectedStrokes{
            drawing.removeStrokeByUUID(stroke.UUID)
        }
    }
    
    func copy() -> Tool {
        return Lasso(stroke: self.stroke, seletedStrokes: self.selectedStrokes, state:  self.state)
    }
    
}


protocol LassoState {
    func update(context: Lasso)
    func beginDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView)
    func continueDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView)
    func finishDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView)
    func determineSelectedPaths(lassoStroke: Stroke, selectFrom drawing: Drawing)
    func checkState(position: CGPoint, canvasView: CanvasView)
    func translateStroke(position: CGPoint, previousPosition: CGPoint, translateFrom drawing: Drawing)
}

class LassoBaseState: LassoState{
    private(set) weak var context: Lasso?
    
    func update(context: Lasso) {
        self.context = context
    }
    
    func beginDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){}
    
    func continueDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){}
    
    func finishDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){}
    
    func determineSelectedPaths(lassoStroke: Stroke, selectFrom drawing: Drawing){}
    
    func checkState(position: CGPoint, canvasView: CanvasView){}
    
    func translateStroke(position: CGPoint, previousPosition: CGPoint, translateFrom drawing: Drawing){}
}


class SelectingState: LassoBaseState{
    
    override func beginDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){
        canvasView.drawing.removeLassoStrokes()
        canvasViewDelegate.beginStrokeBuilding(touch, canvasView)
        checkState(position: touch.location(in: canvasView), canvasView: canvasView)
    }
    
    override func continueDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){
        canvasViewDelegate.strokeBuilding(touch, canvasView)
    }
    
    override func finishDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView){
        canvasViewDelegate.closeStroke(touch, canvasView)
        
        if let lasso = context{
        
            if canvasViewDelegate.timerForTap > 0.01 && canvasViewDelegate.timerForTap < 0.1 && (SelectionMenuView.selectionMenu.menuOptions == SelectionMenuView.selectionMenu.pasteOptions || !lasso.selectedStrokes.isEmpty){
                SelectionMenuView.selectionMenu.useMenu(atPoint: touch.location(in: canvasView))
                context?.transitionTo(state: TranslationState())
                print("transition to TranslationState")
            }
        }
    }
    
    override func determineSelectedPaths(lassoStroke: Stroke, selectFrom drawing: Drawing){
        var numberOfSelectedStrokes = 0
        for stroke in drawing.strokes{
            if !stroke.isLasso{
                for point in stroke.pointsMove{
                    if lassoStroke.path.contains(point.applying(stroke.transform)) && lassoStroke.path.bounds.contains(point.applying(stroke.transform)){
                        numberOfSelectedStrokes += 1
                        context?.selectedStrokes.append(stroke)
                        context?.stroke = lassoStroke
                        SelectionMenuView.selectionMenu.setMenuOptions(options: SelectionMenuView.selectionMenu.standardOptions)
                        break
                    }
                    
                }
            }
        }
        
        if numberOfSelectedStrokes != 0{
            drawing.append(lassoStroke)
            context?.transitionTo(state: TranslationState())
            print("transition to TransaltionState")
        }
    }
    
    override func checkState(position: CGPoint, canvasView: CanvasView){
        if let lasso = context{
            
            for stroke in canvasView.drawing.strokes{
                if let line = stroke as? Line{
                    for point in line.pointsMove{
                        if cgDistance(point1: point.applying(line.transform), point2: position) < 10{
                            lasso.selectedStrokes = [stroke]
                            lasso.transitionTo(state: EditByHandlesState())
                            print("transition to EditByHandlesState")
                            return
                        }
                    }
                }
                
                if let image = stroke as? ImageStroke{
                    for point in image.pointsMove{
                        if cgDistance(point1: point.applying(image.transform), point2: position) < 10{
                            lasso.selectedStrokes = [stroke]
                            image.bindModifier(sender: canvasView)
                            lasso.transitionTo(state: EditByHandlesState())
                            print("transition to EditByHandlesState")
                            return
                        }
                    }
                }
            }
            
            if lasso.stroke.path.contains(position) && lasso.stroke.path.bounds.contains(position){
                lasso.transitionTo(state: TranslationState())
                print("transition to TranslationState")
            }
            else{
                lasso.selectedStrokes = []
                lasso.stroke = Stroke()
                SelectionMenuView.selectionMenu.resetMenu()
            }
            
            
        }
    }
}

class TranslationState: LassoBaseState{
    override func beginDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView) {
        checkState(position: touch, canvasView: canvasView, by: canvasViewDelegate)
        canvasView.drawing.removeLassoStrokes()
        SelectionMenuView.selectionMenu.resetMenu()
    }
    
    override func finishDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView) {
        if let lasso = context{
            canvasView.drawing.append(lasso.stroke)
        }
        SelectionMenuView.selectionMenu.useMenu(atPoint: touch.location(in: canvasView))
    }
    
    override func checkState(position: CGPoint, canvasView: CanvasView){
        if let lasso = context{
            if SelectionMenuView.selectionMenu.copy.count > 0 && SelectionMenuView.selectionMenu.menuOptions == SelectionMenuView.selectionMenu.pasteOptions{
                
                SelectionMenuView.selectionMenu.useMenu(atPoint: position)

                lasso.stroke = Stroke()
                lasso.selectedStrokes = []
                lasso.transitionTo(state: SelectingState())
                print("transition to SelectingState1")
                
            }
            else if !lasso.stroke.path.contains(position) || !lasso.stroke.path.bounds.contains(position){
                
                lasso.stroke = Stroke()
                lasso.selectedStrokes = []
                SelectionMenuView.selectionMenu.resetMenu()
                lasso.transitionTo(state: SelectingState())
                
                print("transition to SelectingState2")
                
            }
        }
    }
    
    func checkState(position touch: UITouch, canvasView: CanvasView, by canvasViewDelegate: CVDelegate){
        if let lasso = context{
            if SelectionMenuView.selectionMenu.copy.count > 0 && SelectionMenuView.selectionMenu.menuOptions == SelectionMenuView.selectionMenu.pasteOptions{
                
                SelectionMenuView.selectionMenu.useMenu(atPoint: touch.location(in: canvasView))

                lasso.stroke = Stroke()
                lasso.selectedStrokes = []
                lasso.transitionTo(state: SelectingState())
                lasso.beginDrawing(by: canvasViewDelegate, with: touch, in: canvasView)
                print("transition to SelectingState1")
                
            }
            else if !lasso.stroke.path.contains(touch.location(in: canvasView)) || !lasso.stroke.path.bounds.contains(touch.location(in: canvasView)){
                lasso.stroke = Stroke()
                lasso.selectedStrokes = []
                SelectionMenuView.selectionMenu.resetMenu()
                lasso.transitionTo(state: SelectingState())
                lasso.beginDrawing(by: canvasViewDelegate, with: touch, in: canvasView)
                print("transition to SelectingState2")
                
            }
        }
    }
    
    
    
    override func translateStroke(position: CGPoint, previousPosition: CGPoint, translateFrom drawing: Drawing){
        let deltaX = position.x - previousPosition.x
        let deltaY = position.y - previousPosition.y
        
        let transform = CGAffineTransform(translationX: deltaX, y: deltaY)
        
        if let lasso = context{
            lasso.stroke.apply(transform)
            
            for selectedStroke in lasso.selectedStrokes {
                drawing.translateStroke(UUID: selectedStroke.UUID, translateWith: transform)
                
            }
        }
    }
}

class EditByHandlesState: LassoBaseState{
    override func beginDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView) {
        checkState(position: touch, canvasView: canvasView, by: canvasViewDelegate)
    }
    
    override func finishDrawing(by canvasViewDelegate: CVDelegate, with touch: UITouch, in canvasView: CanvasView) {
        checkState(position: touch, canvasView: canvasView, by: canvasViewDelegate)
    }
    
    override func checkState(position: CGPoint, canvasView: CanvasView) {
        if let lasso = context{
            for stroke in lasso.selectedStrokes{
                if let image = stroke as? ImageStroke{
                    if image.UUID == stroke.UUID{
                        
                        var minDist = cgDistance(point1: image.pointsMove[0].applying(image.transform), point2: position)
                        
                        for point in image.pointsMove{
                            let dist = cgDistance(point1: point.applying(image.transform), point2: position)
                            if dist < minDist{
                                minDist = dist
                            }
                            
                            if minDist > 100{
                                image.unBindModifier(sender: canvasView)
                                lasso.selectedStrokes = []
                                lasso.transitionTo(state: SelectingState())
                                print("transition to SelectingState")
                            }
                        }
                    }
                }
                
                if let line = stroke as? Line{
                    if line.UUID == stroke.UUID{
                        
                        var minDist = cgDistance(point1: line.pointsMove[0].applying(line.transform), point2: position)
                        
                        for point in line.pointsMove{
                            let dist = cgDistance(point1: point.applying(line.transform), point2: position)
                            if dist < minDist{
                                minDist = dist
                            }
                            
                            if minDist > 100{
                                //line.unBindModifier(sender: canvasView)
                                lasso.selectedStrokes = []
                                lasso.transitionTo(state: SelectingState())
                                print("transition to SelectingState")
                            }
                        }
                    }
                }
            }
            
        }
    }
        
    func checkState(position touch: UITouch, canvasView: CanvasView, by canvasViewDelegate: CVDelegate) {
        if let lasso = context{
            for stroke in lasso.selectedStrokes{
                if let image = stroke as? ImageStroke{
                    if image.UUID == stroke.UUID{
                        
                        var minDist = cgDistance(point1: image.pointsMove[0].applying(image.transform), point2: touch.location(in: canvasView))
                        
                        for point in image.pointsMove{
                            let dist = cgDistance(point1: point.applying(image.transform), point2: touch.location(in: canvasView))
                            if dist < minDist{
                                minDist = dist
                            }
                            
                            if minDist > 100{
                                image.unBindModifier(sender: canvasView)
                                lasso.selectedStrokes = []
                                lasso.transitionTo(state: SelectingState())
                                lasso.beginDrawing(by: canvasViewDelegate, with: touch, in: canvasView)
                                print("transition to SelectingState")
                            }
                        }
                    }
                }
                
                if let line = stroke as? Line{
                    if line.UUID == stroke.UUID{
                        
                        var minDist = cgDistance(point1: line.pointsMove[0].applying(line.transform), point2: touch.location(in: canvasView))
                        
                        for point in line.pointsMove{
                            let dist = cgDistance(point1: point.applying(line.transform), point2: touch.location(in: canvasView))
                            if dist < minDist{
                                minDist = dist
                            }
                            
                            if minDist > 100{
                                //line.unBindModifier(sender: canvasView)
                                lasso.selectedStrokes = []
                                lasso.transitionTo(state: SelectingState())
                                lasso.beginDrawing(by: canvasViewDelegate, with: touch, in: canvasView)
                                print("transition to SelectingState")
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func translateStroke(position: CGPoint, previousPosition: CGPoint, translateFrom drawing: Drawing){
        let deltaX = position.x - previousPosition.x
        let deltaY = position.y - previousPosition.y
        
        let transform = CGAffineTransform(translationX: deltaX, y: deltaY)
        
        if let lasso = context{
            lasso.stroke.apply(transform)
            
            for selectedStroke in lasso.selectedStrokes {
                drawing.translateStroke(UUID: selectedStroke.UUID, translateWith: transform)
                
            }
        }
    }
}



