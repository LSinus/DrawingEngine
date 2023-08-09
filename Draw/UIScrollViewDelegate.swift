//
//  UIScrollViewDelegate.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 04/08/23.
//

import Foundation
import UIKit

class UISCVDelegate: NSObject, UIScrollViewDelegate{
    
    var zoomableContentView: CanvasView
    
    init(_ canvasView: CanvasView){
        self.zoomableContentView = canvasView
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomableContentView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView){
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        zoomableContentView.layer.contentsScale = scale
        zoomableContentView.setNeedsDisplay()
    }
}
