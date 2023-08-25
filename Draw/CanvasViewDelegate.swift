//
//  CanvasViewDelegate.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 19/05/23.
//

import Foundation
import UIKit

// MARK: - Public Protocol Declarations

/// CanvasView Delegate
protocol CanvasViewDelegate: AnyObject{
    /**
     ViewDelegate called when a touch gesture begins on the CanvasView.
     
     - Parameter view: View where touches occured.
     */
    func CanvasView(didBeginDrawingIn canvasView: CanvasView, using touch: UITouch)
    
    /**
     ViewDelegate called when touch gestures continue on the CanvasView.
     
     - Parameter view: View where touches occured.
     */
    func CanvasView(isDrawingIn canvasView: CanvasView, using touch: UITouch)
    
    /**
     ViewDelegate called when touches gestures finish on the CanvasView.
     
     - Parameter view: View where touches occured.
     */
    func CanvasView(didFinishDrawingIn canvasView: CanvasView, using touch: UITouch)
    
    func getActualStroke() -> Stroke
    
    func CanvasView(didBeginTappingIn canvasView: CanvasView, using touch: UITouch)
    
    func CanvasView(isTappingIn canvasView: CanvasView, using touch: UITouch)
    
    func CanvasView(didFinishTappingIn canvasView: CanvasView, using touch: UITouch)
}


class CVDelegate: CanvasViewDelegate{
    
    var tempStroke: Stroke = Stroke()
    var previous = CGPoint()
    var previousPrevious = CGPoint()
    
    var clock = Timer()
    var timerForShape: Float = 0
    var timerForTap: Float = 0
    
    var touchesPoint: [CGPoint] = []
    
    let selectionMenu = SelectionMenuView.selectionMenu
    
    func CanvasView(didBeginDrawingIn canvasView: CanvasView, using touch: UITouch) {
        
        startTimerMovementDetection(in: canvasView)
        
        if let lasso = canvasView.tool as? Lasso{
            lasso.checkTraslation(position: touch.location(in: canvasView))
            
            if lasso.isTranslating{
                lasso.beginTranslatingStroke(position: touch.location(in: canvasView), previousPosition: touch.previousLocation(in: canvasView), translateFrom: canvasView.drawing)
                canvasView.drawing.removeLassoStrokes()
                return
            }
        }
        
        //remove old lasso selections
        canvasView.drawing.removeLassoStrokes()
        
        previous = touch.location(in: canvasView)
        previousPrevious = touch.location(in: canvasView)
    
        tempStroke.path.move(to: previous)
        tempStroke.pointsMove.append(previous)
                
        if let eraser = canvasView.tool as? EraserBit{
            eraser.erase(eraseLine: tempStroke, eraseFrom: canvasView.drawing)
        }
        if let eraser = canvasView.tool as? EraserVec{
            eraser.erase(eraseLine: tempStroke, eraseFrom: canvasView.drawing)
        }

        RenderCanvas(canvasView)
        
        touchesPoint.append(previous)
    }
    
    func CanvasView(isDrawingIn canvasView: CanvasView, using touch: UITouch) {
        //let vel = calcVelocity(now: time, previousDate: previousTime, point: touch.location(in: canvasView), previousPoint: previous)
        
        if let lasso = canvasView.tool as? Lasso{
            if lasso.isTranslating{
                selectionMenu.resetMenu()
                lasso.translateStroke(position: touch.location(in: canvasView), previousPosition: touch.previousLocation(in: canvasView), translateFrom: canvasView.drawing)
                RenderCanvas(canvasView)
                return
            }
            
            //lasso.calculateDashSize(vel: vel)
        }
        previousPrevious = previous
        previous = touch.previousLocation(in: canvasView)
        
        
        strokeBuilding(touch, canvasView)
        
                    
        if let eraser = canvasView.tool as? EraserVec{
            eraser.erase(eraseLine: tempStroke, eraseFrom: canvasView.drawing)
            RenderCanvas(canvasView)
        }
        if let eraser = canvasView.tool as? EraserBit{
            eraser.erase(eraseLine: tempStroke, eraseFrom: canvasView.drawing)
            RenderCanvas(canvasView)
        }
        
        let rectToRender = CGRect(x: (tempStroke.path.bounds.minX - 20), y: (tempStroke.path.bounds.minY - 20), width: (tempStroke.path.bounds.width + 50), height: (tempStroke.path.bounds.height + 50))
        RenderCanvas(canvasView, rect: rectToRender)
        
        touchesPoint.append(touch.location(in: canvasView))
    }
    
    func CanvasView(didFinishDrawingIn canvasView: CanvasView, using touch: UITouch) {
        if let lasso = canvasView.tool as? Lasso{
            if lasso.isTranslating{
                if timerForTap > 0.01 && timerForTap < 0.1{
                    selectionMenu.useMenu(atPoint: touch.location(in: canvasView))
                }
                canvasView.drawing.append([lasso.stroke])
            }
            else{
                if tempStroke.pointsMove.count > 0{
                    //closing tempStroke
                    tempStroke.path.move(to: tempStroke.path.cgPath.currentPoint)
                    tempStroke.path.addLine(to: tempStroke.pointsMove[0])
                    
                    //determine selected paths
                    let numberOfSelectedStrokes = lasso.determineSelectedPaths(lassoStroke: tempStroke, selectFrom: canvasView.drawing)
                    if numberOfSelectedStrokes != 0 {
                        canvasView.drawing.strokes.append(tempStroke)
                    }
                }
            }
            tempStroke = Stroke()
            RenderCanvas(canvasView)
            touchesPoint = []
            clock.invalidate()
            timerForShape = 0
            timerForTap = 0
            return
        }
            
        previousPrevious = previous
        previous = touch.previousLocation(in: canvasView)
                
        strokeBuilding(touch, canvasView)
    
        if let eraser = canvasView.tool as? EraserVec{
            eraser.erase(eraseLine: tempStroke, eraseFrom: canvasView.drawing)
        }
        if let eraser = canvasView.tool as? EraserBit{
            eraser.erase(eraseLine: tempStroke, eraseFrom: canvasView.drawing)
            eraser.isErasing = false
        }
        if let marker = canvasView.tool as? Marker{
            marker.Mark(markerStroke: tempStroke, markFrom: canvasView.drawing)
        } 
        if let _ = canvasView.tool as? Pen{
            canvasView.drawing.strokes.append(tempStroke)
        }
        
        tempStroke = Stroke()
        RenderCanvas(canvasView)
        
        touchesPoint = []
        clock.invalidate()
        timerForShape = 0
        timerForTap = 0
    }
    
    func RenderCanvas(_ view: UIView){
        view.setNeedsDisplay()
    }
    
    func RenderCanvas(_ view: UIView, rect: CGRect){
        view.setNeedsDisplay(rect)
    }
    
    func getActualStroke() -> Stroke {
        return tempStroke
    }
    
    func strokeBuilding(_ touch: UITouch, _ canvasView: UIView){
        tempStroke.path.move(to: getMidPoint(from: previousPrevious, to: previous))
        tempStroke.pointsMove.append(getMidPoint(from: previousPrevious, to: previous))
        tempStroke.path.addQuadCurve(to: getMidPoint(from: touch.location(in: canvasView), to: previous), controlPoint: previous)
        tempStroke.pointsTo.append(getMidPoint(from: touch.location(in: canvasView), to: previous))
        tempStroke.controlPoints.append(previous)
    }
    
    func CanvasView(didBeginTappingIn canvasView: CanvasView, using touch: UITouch){
        if SelectionMenuView.selectionMenu.copy.count > 0{
            SelectionMenuView.selectionMenu.useMenu(atPoint: touch.location(in: canvasView))
        }
        
        
        if let lasso = canvasView.tool as? Lasso{
//            lasso.checkTraslation(position: touch.location(in: canvasView))
//
            if lasso.isTranslating{
                selectionMenu.useMenu(atPoint: touch.location(in: canvasView))
//                lasso.beginTranslatingStroke(position: touch.location(in: canvasView), previousPosition: touch.previousLocation(in: canvasView), translateFrom: canvasView.drawing)
//                canvasView.drawing.removeLassoStrokes()
//                return
            }
        }
    }
    
    func CanvasView(isTappingIn canvasView: CanvasView, using touch: UITouch){
//        if let lasso = canvasView.tool as? Lasso{
//            if lasso.isTranslating{
//                lasso.translateStroke(position: touch.location(in: canvasView), previousPosition: touch.previousLocation(in: canvasView), translateFrom: canvasView.drawing)
//                RenderCanvas(canvasView)
//                return
//            }
//
//            //lasso.calculateDashSize(vel: vel)
//        }
    }
    
    func CanvasView(didFinishTappingIn canvasView: CanvasView, using touch: UITouch) {
//        if let lasso = canvasView.tool as? Lasso{
//            if lasso.isTranslating{
//                canvasView.drawing.append([lasso.stroke])
//            }
//            else{
//                if tempStroke.pointsMove.count > 0{
//                    //closing tempStroke
//                    tempStroke.path.move(to: tempStroke.path.cgPath.currentPoint)
//                    tempStroke.path.addLine(to: tempStroke.pointsMove[0])
//
//                    //determine selected paths
//                    let numberOfSelectedStrokes = lasso.determineSelectedPaths(lassoStroke: tempStroke, selectFrom: canvasView.drawing)
//                    if numberOfSelectedStrokes != 0 {
//                        canvasView.drawing.strokes.append(tempStroke)
//                    }
//                }
//            }
//            tempStroke = Stroke()
//            RenderCanvas(canvasView)
//            return
//        }
    }
    
    func startTimerMovementDetection(in canvasView: CanvasView){
        var isDrawn = false
        
        self.clock = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true){ [weak self] timer in
            DispatchQueue.main.async {
                
                self?.timerForShape += 0.001
                self?.timerForTap += 0.001
                
                if self!.touchesPoint.count > 2{
                    
                    if cgDistance(point1: self!.touchesPoint[self!.touchesPoint.count-1], point2: self!.touchesPoint[self!.touchesPoint.count-2]) > 0.2 && !isDrawn{
                        self?.timerForShape = 0
                    }
                    
                    if self!.timerForShape >= 0.5 && self!.timerForShape < 0.501{
                        let shape = self!.detectShape()
                        shape.path.lineWidth = self!.tempStroke.path.lineWidth
                        self?.tempStroke = shape
                        self?.RenderCanvas(canvasView)
                        isDrawn = true
                    }
                    
                    if self!.timerForShape >= 0.501 && isDrawn{
                        if let line = self?.tempStroke as? Line{
                            print(self!.touchesPoint[self!.touchesPoint.endIndex-1])
                            let shape = Line(startPoint: line.startPoint, endPoint: self!.touchesPoint[self!.touchesPoint.endIndex-1], color: line.color)
                            shape.path.lineWidth = self!.tempStroke.path.lineWidth
                            self?.tempStroke = shape
                            self?.RenderCanvas(canvasView)
                        }
                    }
                }
                
            }
        }
    }
    
    func detectShape() -> Stroke{
        //print("detectShape")
        //MARK: Straight Line
        var isLine = true
        let lineTolerance = 35.0
        let coefficient = (touchesPoint[touchesPoint.count-1].y - touchesPoint[0].y) / (touchesPoint[touchesPoint.count-1].x - touchesPoint[0].x)
        
        let constant = touchesPoint[0].y - coefficient*touchesPoint[0].x
        
        for point in touchesPoint {
            let exactY = coefficient*point.x + constant
            if(abs(point.y - exactY) > lineTolerance){
                isLine = false
            }
        }
        
        if(!isLine){
            var precX = touchesPoint[0].x
            var isVertical = true
            
            for point in touchesPoint {
                if(abs(point.x - precX) > lineTolerance/10){
                    isVertical = false
                }
                precX = point.x
            }
            
            if(isVertical){
                isLine = true
            }
        }
        
        
        if(isLine){
            let line = Line(startPoint: tempStroke.pointsMove[0], endPoint: tempStroke.path.currentPoint, color: tempStroke.color)
            return line
        }
        
        
        return tempStroke
    }
}
