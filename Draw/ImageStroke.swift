//
//  ImageStroke.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 25/08/23.
//

import Foundation
import UIKit

class ImageStroke: Stroke{
    var image: UIImage
    var renderPath: UIBezierPath
    var renderRect: CGRect
    
    init(image: UIImage, at originPoint: CGPoint) {
        self.image = image
        self.renderRect = CGRect(origin: originPoint, size: image.size)
        self.renderPath = UIBezierPath()
        renderPath.move(to: CGPoint(x: renderRect.minX, y: renderRect.minY))
        renderPath.addLine(to: CGPoint(x: renderRect.maxX, y: renderRect.minY))
        renderPath.addLine(to: CGPoint(x: renderRect.maxX, y: renderRect.maxY))
        renderPath.addLine(to: CGPoint(x: renderRect.minX, y: renderRect.maxY))
        renderPath.addLine(to: CGPoint(x: renderRect.minX, y: renderRect.minY))
        
        super.init(path: renderPath, color: .clear)
        
    }
    
    init(image: UIImage, renderPath: UIBezierPath, renderRect: CGRect) {
        self.image = image
        self.renderRect = renderRect
        self.renderPath = renderPath
        super.init(path: renderPath, color: .clear)
    }
    
    override func draw() {
        super.draw()
        image.draw(in: renderRect)
    }
    
    override func apply(_ transfrom: CGAffineTransform) {
        super.apply(transfrom)
        renderRect = renderRect.applying(transfrom)
    }
    
    override func copy() -> Stroke {
        let copy = ImageStroke(image: self.image, renderPath: self.renderPath, renderRect: self.renderRect)
        return copy
    }
}
