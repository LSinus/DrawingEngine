//
//  drawView.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 15/05/23.
//

import UIKit
import SwiftUI

open class CanvasView: UIView{
    
    var drawing: Drawing
    var tool: Tool

    weak var delegate: CanvasViewDelegate?
    
    lazy private var pencilInteraction = UIPencilInteraction()
    
    /// Public init(frame:) implementation
    override public init(frame: CGRect) {
        self.drawing = Drawing()
        self.tool = Pen(width: 3, color: .red)
        super.init(frame: frame)
        commonInit()
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        self.drawing = Drawing()
        self.tool = Pen(width: 10, color: .red)
        super.init(coder: aDecoder)
        commonInit()
    }
    
    init(frame: CGRect, drawing: Drawing, tool: Tool){
        self.drawing = drawing
        self.tool = tool
        super.init(frame: frame)
        commonInit()

    }
    
    func commonInit(){
        self.clipsToBounds = true
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.red.cgColor
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            //print("touch Position: \(touch.location(in: self))")
            
            if(touch.type == .pencil){
                delegate?.CanvasView(didBeginDrawingIn: self, using: touch)
            }
            else{
                delegate?.CanvasView(didBeginTappingIn: self, using: touch)
            }
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if(touch.type == .pencil){
                delegate?.CanvasView(isDrawingIn: self, using: touch)
            }
            else{
                delegate?.CanvasView(isTappingIn: self, using: touch)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if(touch.type == .pencil){
                delegate?.CanvasView(didFinishDrawingIn: self, using: touch)
                UndoManager.undoManager.performAction()
            }
            else{
                delegate?.CanvasView(didFinishTappingIn: self, using: touch)
            }
            
            
        }
    }
    
    override open func draw(_ rect: CGRect){
        if(tool.type != .Marker){
            for stroke in drawing.strokes{
                stroke.draw()
            }
            if(tool.type == .EraserBit){
                let path = UIBezierPath(rect: rect)
                UIColor.clear.setFill()
                path.fill()
            }
            delegate?.getActualStroke().draw(with: tool) ?? Stroke().draw()
        }
        else{
            delegate?.getActualStroke().draw(with: tool) ?? Stroke().draw()
            for stroke in drawing.strokes{
                stroke.draw()
            }
        }
    }
    
    func copyCanvas() -> CanvasView{
        let copiedDrawing = drawing.copy()
        let copiedTool = tool.copy()
        
        return CanvasView(frame: self.frame, drawing: copiedDrawing, tool: copiedTool)
    }
}
