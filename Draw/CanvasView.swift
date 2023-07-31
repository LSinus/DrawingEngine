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
    var tempStroke: Stroke
    var tool: Tool
    var previous = CGPoint()
    var previousPrevious = CGPoint()
    var prova = ""
    
    
    var delegate: CanvasViewDelegate?
    
    lazy private var pencilInteraction = UIPencilInteraction()
    /// Public init(frame:) implementation
    override public init(frame: CGRect) {
        self.tempStroke = Stroke()
        self.drawing = Drawing()
        self.tool = Pen(width: 3, color: .red)
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        self.tempStroke = Stroke()
        self.drawing = Drawing()
        self.tool = Pen(width: 10, color: .red)
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.addGestureRecognizer(tap)
    }

    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            
            delegate?.CanvasView(isDrawingIn: self, using: touch)
            print(prova)
            //print(touch.location(in: self))
            
            if(touch.type == .pencil){
                
                //remove old lasso selections
                drawing.removeLassoStrokes()
            
                tempStroke.path.move(to: touch.location(in: self))
                tempStroke.pointsMove.append(touch.location(in: self))
                
                setNeedsDisplay()
                previous = touch.location(in: self)
                previousPrevious = touch.location(in: self)
                
                if(tool.type == .EraserVec){
                    if let eraser = tool as? EraserVec{
                        drawing = eraser.erase(eraseLine: tempStroke, eraseFrom: drawing)
                    }
                    setNeedsDisplay()
                }
//                if(tool.type == .Lasso){
//                    if let lasso = tool as? Lasso{
//                        drawing = lasso.determineSelectedPaths(lassoStroke: tempStroke, selectFrom: drawing)
//                    }
//                    setNeedsDisplay()
//                }
            }
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            
            if(touch.type == .pencil){
                //print(touch.force)
                previousPrevious = previous
                previous = touch.previousLocation(in: self)
                
                tempStroke.path.move(to: getMidPoint(from: previousPrevious, to: previous))
                tempStroke.pointsMove.append(getMidPoint(from: previousPrevious, to: previous))
                
                tempStroke.path.addQuadCurve(to: getMidPoint(from: touch.location(in: self), to: previous), controlPoint: previous)
                tempStroke.pointsTo.append(getMidPoint(from: touch.location(in: self), to: previous))
                tempStroke.controlPoints.append(previous)
                
                let newRect = CGRect(x: (tempStroke.path.bounds.minX - 20), y: (tempStroke.path.bounds.minY - 20), width: (tempStroke.path.bounds.width + 50), height: (tempStroke.path.bounds.height + 50))
                
                if(tool.type == .EraserVec){
                    if let eraser = tool as? EraserVec{
                        drawing = eraser.erase(eraseLine: tempStroke, eraseFrom: drawing)
                    }
                    setNeedsDisplay()
                }
                if(tool.type == .EraserBit){
                    if let eraser = tool as? EraserBit{
                        drawing = eraser.erase(eraseLine: tempStroke, eraseFrom: drawing)
                    }
                    setNeedsDisplay()
                }
//                if(tool.type == .Lasso){
//                    if let lasso = tool as? Lasso{
//                        drawing = lasso.determineSelectedPaths(lassoStroke: tempStroke, selectFrom: drawing)
//                    }
//                    setNeedsDisplay()
//                }
                
                setNeedsDisplay(newRect)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            
            if(touch.type == .pencil){
                if(tool.type != .Lasso){
                    previousPrevious = previous
                    previous = touch.previousLocation(in: self)
                    
                    tempStroke.path.move(to: getMidPoint(from: previousPrevious, to: previous))
                    tempStroke.pointsMove.append(getMidPoint(from: previousPrevious, to: previous))
                    
                    tempStroke.path.addQuadCurve(to: getMidPoint(from: touch.location(in: self), to: previous), controlPoint: previous)
                    tempStroke.pointsTo.append(getMidPoint(from: touch.location(in: self), to: previous))
                    tempStroke.controlPoints.append(previous)
                }
                
                if(tool.type == .EraserVec){
                    if let eraser = tool as? EraserVec{
                        drawing = eraser.erase(eraseLine: tempStroke, eraseFrom: drawing)
                    }
                }
                
                if(tool.type == .EraserBit){
                    if let eraser = tool as? EraserBit{
                        drawing = eraser.erase(eraseLine: tempStroke, eraseFrom: drawing)
                        eraser.isErasing = false
                    }
                }
                
                if(tool.type == .Pen){
                    drawing.strokes.append(tempStroke)
                }
                
                if(tool.type == .Lasso){
                    tempStroke.path.move(to: tempStroke.path.cgPath.currentPoint)
                    tempStroke.path.addLine(to: tempStroke.pointsMove[0])
                    
                    if let lasso = tool as? Lasso{
                        drawing = lasso.determineSelectedPaths(lassoStroke: tempStroke, selectFrom: drawing)
                    }
                    drawing.strokes.append(tempStroke)
                }
                
//                print("pointsMove\(tempStroke.pointsMove.count)")
//                print("pointsTo\(tempStroke.pointsTo.count)")
//                print("controlPoints\(tempStroke.controlPoints.count)")
                
                tempStroke = Stroke()
                setNeedsDisplay()
                
            
            }
        }
    }
    
    override open func draw(_ rect: CGRect){
        
        for stroke in drawing.strokes{
            stroke.draw()
        }
        
        if(tool.type == .EraserBit){
            let path = UIBezierPath(rect: rect)
                UIColor.clear.setFill()
                path.fill()
        }
        
        tempStroke.draw(with: tool)
        
    }
    
    func getMidPoint(from: CGPoint, to: CGPoint) -> CGPoint{
        return CGPoint(x: (from.x + to.x)/2, y: (from.y + to.y)/2)
    }

    // Listener

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        // handling code
        print("tap")
    }


}


open class CVContainer: UIView{
    
    let canvasView = CanvasView(frame: CGRect(x: 10, y: 0, width: 2000, height: 1000))
    let canvasViewDelegate = Delegate()
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.canvasView.delegate = canvasViewDelegate
        self.addSubview(canvasView)
        self.backgroundColor = .clear
        setupGestureRecognizers()
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canvasView.delegate = canvasViewDelegate
        self.addSubview(canvasView)
        self.backgroundColor = .clear
        setupGestureRecognizers()
        
    }
    
    private var currentScale: CGFloat = 1.0
    private var pinchCenter: CGPoint = CGPoint.zero
    private var lastTranslation: CGPoint = .zero

    // Crea il riconoscitore di gesti di pinch
    private lazy var pinchGestureRecognizer: UIPinchGestureRecognizer = {
       let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
       return pinchGesture
    }()
    
    // Crea il riconoscitore di gesti di pan
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        return panGesture
    }()
    
    private func setupGestureRecognizers() {
           // Aggiungi il riconoscitore di gesti di pinch alla vista
        self.addGestureRecognizer(pinchGestureRecognizer)
        
        superview?.addGestureRecognizer(panGestureRecognizer)
        
        panGestureRecognizer.require(toFail: pinchGestureRecognizer)
    }
    
    
    @objc private func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        // Recupera la vista sulla quale è stata effettuata la gesture
        let view = gestureRecognizer.view

        // Aggiorna la scala in base al pinch
        switch gestureRecognizer.state {
        case .began:
            // Registra la scala iniziale al momento in cui inizia il pinch
            currentScale = view?.transform.a ?? 1.0

            // Calcola il punto del pinch rispetto alla vista
            pinchCenter = gestureRecognizer.location(in: view)

        case .changed:
            // Calcola la nuova scala in base al pinch e alla scala iniziale
            let newScale = currentScale * gestureRecognizer.scale

            // Gradua l'effetto di zoom applicando una funzione di interpolazione
            let interpolatedScale = pow(newScale, 0.5) // Modifica il valore dell'esponente per regolare la velocità dello zoom

            // Limita la scala per ottenere uno zoom più moderato
            let minScale: CGFloat = 0.8
            let maxScale: CGFloat = 1.5
            let scaledValue = min(max(interpolatedScale, minScale), maxScale)

            // Calcola la traslazione necessaria per centrare il punto del pinch durante lo zoom
            let deltaX = pinchCenter.x * (1 - scaledValue)
            let deltaY = pinchCenter.y * (1 - scaledValue)

            // Combiniamo la traslazione e la scala usando la funzione concatenating(_:)
            let transform = CGAffineTransform(translationX: deltaX, y: deltaY).scaledBy(x: scaledValue, y: scaledValue)

            // Applica la trasformazione di zoom e traslazione alla vista
            view?.transform = transform

        default:
            break
        }
            setNeedsDisplay()
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
            // Recupera la vista sulla quale è stata effettuata la gesture
            let view = gestureRecognizer.view

            // Muoviti all'interno della vista zoomata usando la traslazione
            switch gestureRecognizer.state {
            case .began, .changed:
                // Recupera la traslazione dal gesto di pan
                let translation = gestureRecognizer.translation(in: view)

                // Applica la traslazione alla vista tenendo conto della scala
                let scaledTranslation = CGPoint(x: translation.x / currentScale, y: translation.y / currentScale)
                let transformedTranslation = CGPoint(x: lastTranslation.x + scaledTranslation.x, y: lastTranslation.y + scaledTranslation.y)

                // Applica la traslazione alla vista
                view?.transform = view?.transform.translatedBy(x: transformedTranslation.x, y: transformedTranslation.y) ?? .identity

                // Salva la traslazione per il prossimo gesto di pan
                lastTranslation = transformedTranslation

                // Reimposta la traslazione del gesture recognizer per evitare la crescita continua del valore
                gestureRecognizer.setTranslation(.zero, in: view)

            case .ended, .cancelled:
                // Salva l'ultima posizione di traslazione per il prossimo gesto di pan
                lastTranslation = .zero

            default:
                break
            }
        }
    
        
}




struct DrawView {
    @Binding var cvContainer: CVContainer
}

extension DrawView: UIViewRepresentable {
    func makeUIView(context: Context) -> CVContainer {
        return cvContainer
    }
    func updateUIView(_ uiView: CVContainer, context: Context) {
        
    }
    

    
}

