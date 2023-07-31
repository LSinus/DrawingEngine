//
//  CanvasViewDelegate.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 19/05/23.
//

import Foundation
import UIKit

// MARK: - Public Protocol Declarations

/// SwiftyDrawView Delegate
protocol CanvasViewDelegate: AnyObject {
    
    /**
     SwiftyDrawViewDelegate called when a touch gesture should begin on the SwiftyDrawView using given touch type
     
     - Parameter view: SwiftyDrawView where touches occured.
     - Parameter touchType: Type of touch occuring.
     */
    func CanvasView(shouldBeginDrawingIn drawingView: CanvasView, using touch: UITouch) -> Bool
    /**
     SwiftyDrawViewDelegate called when a touch gesture begins on the SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func CanvasView(didBeginDrawingIn drawingView: CanvasView, using touch: UITouch)
    
    /**
     SwiftyDrawViewDelegate called when touch gestures continue on the SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func CanvasView(isDrawingIn drawingView: CanvasView, using touch: UITouch)
    
    /**
     SwiftyDrawViewDelegate called when touches gestures finish on the SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func CanvasView(didFinishDrawingIn drawingView: CanvasView, using touch: UITouch)
    
    /**
     SwiftyDrawViewDelegate called when there is an issue registering touch gestures on the  SwiftyDrawView.
     
     - Parameter view: SwiftyDrawView where touches occured.
     */
    func CanvasView(didCancelDrawingIn drawingView: CanvasView, using touch: UITouch)
}


class Delegate: CanvasViewDelegate{
    func CanvasView(shouldBeginDrawingIn drawingView: CanvasView, using touch: UITouch) -> Bool {
        return true
    }
    
    func CanvasView(didBeginDrawingIn drawingView: CanvasView, using touch: UITouch) {
        print(touch.location(in: drawingView))
        
    }
    
    func CanvasView(isDrawingIn drawingView: CanvasView, using touch: UITouch) {
        print(touch.location(in: drawingView))
    }
    
    func CanvasView(didFinishDrawingIn drawingView: CanvasView, using touch: UITouch) {
        print(touch.location(in: drawingView))
    }
    
    func CanvasView(didCancelDrawingIn drawingView: CanvasView, using touch: UITouch) {
        print(touch.location(in: drawingView))
    }
}
