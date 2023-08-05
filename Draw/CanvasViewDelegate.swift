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
}


class CVDelegate: CanvasViewDelegate{
    
    var tempStroke: Stroke = Stroke()
    var previous = CGPoint()
    var previousPrevious = CGPoint()
    var time = Date()
    var previousTime = Date()
    
    func CanvasView(didBeginDrawingIn canvasView: CanvasView, using touch: UITouch) {
        if let lasso = canvasView.tool as? Lasso{
            lasso.checkTraslation(position: touch.location(in: canvasView))
            
            if lasso.isTranslating{
                let popup = Popup(frame: CGRect(x:touch.location(in: canvasView).x-100, y:touch.location(in: canvasView).y-100, width: 200, height: 50))
                canvasView.addSubview(popup)
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
    }
    
    func CanvasView(isDrawingIn canvasView: CanvasView, using touch: UITouch) {
        
        previousTime = time
        time = Date()
        //let vel = calcVelocity(now: time, previousDate: previousTime, point: touch.location(in: canvasView), previousPoint: previous)
        
        if let lasso = canvasView.tool as? Lasso{
            if lasso.isTranslating{
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
        
        let newRect = CGRect(x: (tempStroke.path.bounds.minX - 20), y: (tempStroke.path.bounds.minY - 20), width: (tempStroke.path.bounds.width + 50), height: (tempStroke.path.bounds.height + 50))
        RenderCanvas(canvasView, rect: newRect)
    }
    
    func CanvasView(didFinishDrawingIn canvasView: CanvasView, using touch: UITouch) {
        if let lasso = canvasView.tool as? Lasso{
            if lasso.isTranslating{
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
    
    func calcVelocity(now: Date, previousDate: Date, point: CGPoint, previousPoint: CGPoint) -> CGFloat{
        let timeInterval = now.timeIntervalSince(previousDate)
        let distance = cgDistance(point1: point, point2: previousPoint)
        
        let velocity = distance / timeInterval
        
        return velocity
    }
}
