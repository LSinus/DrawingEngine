//
//  UndoManager.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 10/08/23.
//

import Foundation
import UIKit


class UndoManager{
    static let undoManager = UndoManager()
    private var currentAction = Drawing()
    private var canvasView: CanvasView?
    var undoStack = UndoStack<Drawing>()
    
    func assignView(_ canvasView: CanvasView){
        self.canvasView = canvasView
    }
    
    
    func performAction(){
        if let canvasView = canvasView{
            undoStack.performAction(currentAction)
            currentAction = canvasView.drawing.copy()
        }
    }
    
    func undo(){
        if undoStack.canUndo{
            canvasView?.drawing = undoStack.undo() ?? Drawing()
            canvasView?.setNeedsDisplay()
        }
    }

    func redo(){
        if undoStack.canRedo{
            canvasView?.drawing = undoStack.redo() ?? Drawing()
        }
        else{
            canvasView?.drawing = currentAction
        }
        canvasView?.setNeedsDisplay()
    }
}


