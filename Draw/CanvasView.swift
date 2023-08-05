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
        self.backgroundColor = .clear
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.red.cgColor
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        self.drawing = Drawing()
        self.tool = Pen(width: 10, color: .red)
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if(touch.type == .pencil){
                delegate?.CanvasView(didBeginDrawingIn: self, using: touch)
            }
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if(touch.type == .pencil){
                delegate?.CanvasView(isDrawingIn: self, using: touch)
            }
        }
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            if(touch.type == .pencil){
                delegate?.CanvasView(didFinishDrawingIn: self, using: touch)
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
}

open class CVContainer: UIView{
    
    let canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 5000))
    let canvasViewDelegate = CVDelegate()
    let scrollViewDelegate: UISCVDelegate
    var scrollView: UIScrollView!
    
    override public init(frame: CGRect) {
        self.scrollViewDelegate = UISCVDelegate(canvasView)
        super.init(frame: frame)
        self.canvasView.delegate = canvasViewDelegate
        self.backgroundColor = .clear
        setupScrollView()
        //setupGestureRecognizers()
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        self.scrollViewDelegate = UISCVDelegate(canvasView)
        super.init(coder: aDecoder)
        self.canvasView.delegate = canvasViewDelegate
        self.backgroundColor = .clear
        setupScrollView()
        //setupGestureRecognizers()
        
    }
    
    private func setupScrollView() {
        // Crea l'istanza dello UIScrollView e imposta le sue proprietà (contenuto, dimensioni, ecc.)
        scrollView = UIScrollView(frame: bounds)
        //scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentSize = CGSize(width: bounds.width, height: 5000) // Esempio: altezza del contenuto dello scrollview
        scrollView.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = scrollViewDelegate
        addSubview(scrollView)
        // Aggiungi le tue sottoviste al UIScrollView
        // Esempio: aggiungi una vista per il contenuto dello UIScrollView
        scrollView.addSubview(canvasView)
        // Crea i constraints per centrare la Subview

        // Configura il layout delle sottoviste all'interno dello UIScrollView
        // Esempio: posiziona le sottoviste all'interno di contentView
    }
}

open class Popup: UIView{
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        createButtons()
    }
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .black
    }
    
    private func createButtons(){
        // Crea la stackView per allineare i bottoni orizzontalmente
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.borderColor = UIColor.black.cgColor
        stackView.layer.borderWidth = 1
        stackView.layer.cornerRadius = 10
        self.addSubview(stackView)
                
        // Crea i bottoni del popup
        let button1 = UIButton(type: .system)
        button1.setTitle("Opzione 1", for: .normal)
        button1.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("Opzione 2", for: .normal)
        button2.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        // Aggiungi i bottoni alla stackView
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        
        // Crea i constraints per centrare la popupView
        NSLayoutConstraint.activate([
            // Crea i constraints per allineare la stackView al centro della popupView
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
           
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        // Aggiungi qui la logica per gestire i tap dei bottoni
               if sender.titleLabel?.text == "Opzione 1" {
                   print("Hai selezionato Opzione 1")
               } else if sender.titleLabel?.text == "Opzione 2" {
                   print("Hai selezionato Opzione 2")
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

