//
//  CanvasViewContainer.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 05/08/23.
//

import SwiftUI
import UIKit

open class CVContainer: UIView{
    
    static var cvContainer = CVContainer()
    
    let canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 5000))
    let selectionMenuViewDelegate: SMVDelegate
    let canvasViewDelegate = CVDelegate()
    let scrollViewDelegate: UISCVDelegate
    var scrollView: UIScrollView!
    
    override private init(frame: CGRect) {
        self.scrollViewDelegate = UISCVDelegate(canvasView)
        self.selectionMenuViewDelegate = SMVDelegate(canvasView)
        UndoManager.undoManager.assignView(canvasView)
        SelectionMenuView.selectionMenu.delegate = selectionMenuViewDelegate
        super.init(frame: frame)
        self.canvasView.delegate = canvasViewDelegate
        self.canvasView.addSubview(SelectionMenuView.selectionMenu)
        self.backgroundColor = .clear
        setupScrollView()
        //setupGestureRecognizers()
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        self.scrollViewDelegate = UISCVDelegate(canvasView)
        self.selectionMenuViewDelegate = SMVDelegate(canvasView)
        UndoManager.undoManager.assignView(canvasView)
        SelectionMenuView.selectionMenu.delegate = selectionMenuViewDelegate
        super.init(coder: aDecoder)
        self.canvasView.delegate = canvasViewDelegate
        self.backgroundColor = .clear
        setupScrollView()
        //setupGestureRecognizers()
        
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView(frame: bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentSize = CGSize(width: bounds.width, height: 5000)
        scrollView.panGestureRecognizer.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        scrollView.minimumZoomScale = 0.5
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = scrollViewDelegate
        addSubview(scrollView)
        scrollView.addSubview(canvasView)
        
        //let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    }
    
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
            let touchPoint = gestureRecognizer.location(in: self)
            let edgeInset: CGFloat = 20.0
            
            if touchPoint.x < edgeInset {
                // Scorrimento a sinistra
                scrollView.contentOffset.x -= 10
            } else if touchPoint.x > self.frame.width - edgeInset {
                // Scorrimento a destra
                scrollView.contentOffset.x += 10
            }
            
            if touchPoint.y < edgeInset {
                // Scorrimento verso l'alto
                scrollView.contentOffset.y -= 10
            } else if touchPoint.y > self.frame.height - edgeInset {
                // Scorrimento verso il basso
                scrollView.contentOffset.y += 10
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

