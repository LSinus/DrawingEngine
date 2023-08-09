//
//  CanvasViewContainer.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 05/08/23.
//

import SwiftUI
import UIKit

open class CVContainer: UIView{
    
    let canvasView = CanvasView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 5000))
    let selectionMenuViewDelegate: SMVDelegate
    let canvasViewDelegate = CVDelegate()
    let scrollViewDelegate: UISCVDelegate
    var scrollView: UIScrollView!
    
    override public init(frame: CGRect) {
        self.scrollViewDelegate = UISCVDelegate(canvasView)
        self.selectionMenuViewDelegate = SMVDelegate(canvasView)
        SelectionMenuView.selectionMenu.delegate = selectionMenuViewDelegate
        super.init(frame: frame)
        self.canvasView.delegate = canvasViewDelegate
        self.backgroundColor = .clear
        setupScrollView()
        //setupGestureRecognizers()
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        self.scrollViewDelegate = UISCVDelegate(canvasView)
        self.selectionMenuViewDelegate = SMVDelegate(canvasView)
        SelectionMenuView.selectionMenu.delegate = selectionMenuViewDelegate
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

