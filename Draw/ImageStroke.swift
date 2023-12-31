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
    private var renderPath: UIBezierPath
    var renderRect: CGRect
    
    weak var modifier: ImageModifier?
    
    init(image: UIImage, at originPoint: CGPoint) {
        self.image = image
        self.renderRect = CGRect(origin: originPoint, size: image.size)
        self.renderPath = UIBezierPath()
        renderPath.move(to: CGPoint(x: renderRect.minX, y: renderRect.minY))
        renderPath.addLine(to: CGPoint(x: renderRect.maxX, y: renderRect.minY))
        renderPath.move(to: CGPoint(x: renderRect.maxX, y: renderRect.minY))
        renderPath.addLine(to: CGPoint(x: renderRect.maxX, y: renderRect.maxY))
        renderPath.move(to: CGPoint(x: renderRect.maxX, y: renderRect.maxY))
        renderPath.addLine(to: CGPoint(x: renderRect.minX, y: renderRect.maxY))
        renderPath.move(to: CGPoint(x: renderRect.minX, y: renderRect.maxY))
        renderPath.addLine(to: CGPoint(x: renderRect.minX, y: renderRect.minY))
        super.init(path: renderPath, color: .clear)
        super.color = .green
        
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
        modifier?.apply(transfrom)
    }
    
    func applyDuringHandle(_ transfrom: CGAffineTransform) {
        super.apply(transfrom)
        renderRect = renderRect.applying(transfrom)
    }
    
    override func copy() -> Stroke {
        let copy = ImageStroke(image: self.image, renderPath: self.renderPath, renderRect: self.renderRect)
        return copy
    }
    
    func bindModifier(sender canvasView: CanvasView){
        if self.modifier == nil{
            let imageModifier = ImageModifier(image: self, sender: canvasView)
            self.modifier = imageModifier
            canvasView.setNeedsDisplay()
        }
    }
    
    func unBindModifier(sender canvasView: CanvasView){
        if self.modifier != nil{
            self.color = .green
            self.modifier?.unBind()
            self.modifier = nil
            print("unbind")
            canvasView.setNeedsDisplay()
        }
    }
}

class ImageModifier{
    var handles: [Handle] = []
    weak var image: ImageStroke?
    
    private weak var sender: CanvasView?
    
    init(image: ImageStroke, sender: CanvasView) {
        self.image = image
        self.sender = sender
        for i in 1..<image.pointsMove.count{
            
            let handle = Handle(frame: CGRect(x: image.pointsMove[i].applying(image.transform).x-5, y: image.pointsMove[i].applying(image.transform).y-5, width: 10, height: 10))
            print("handle created")
            handle.modifier = self
            
            sender.addSubview(handle)
            self.handles.append(handle)
            
            image.color = .systemBlue
        }
    }
    
    func getContext() -> CanvasView?{
        return self.sender
    }
    
    func apply(_ transform: CGAffineTransform){
        for handle in handles {
            handle.apply(transform)
        }
    }
    
    func resize(sender handle: Handle, position: CGPoint, previousPosition: CGPoint){
        
        let deltaX = (position.x - previousPosition.x)
        let deltaY = (position.y - previousPosition.y)
        
        var newSize = CGSize()
        
        var anchorForTranslation = CGPoint()
        
        for handleToTranslate in handles{
            if handleToTranslate.frame.origin.x == handle.frame.origin.x && handleToTranslate != handle{
                let transform = CGAffineTransform(translationX: deltaX, y: 0)
                handleToTranslate.apply(transform)
                newSize.height = abs(handleToTranslate.frame.origin.y - handle.frame.origin.y)
                anchorForTranslation.y = handleToTranslate.frame.origin.y
            }
            if handleToTranslate.frame.origin.y == handle.frame.origin.y && handleToTranslate != handle{
                let transform = CGAffineTransform(translationX: 0, y: deltaY)
                handleToTranslate.apply(transform)
                newSize.width = abs(handleToTranslate.frame.origin.x - handle.frame.origin.x)
                anchorForTranslation.x = handleToTranslate.frame.origin.x
            }
            
        }
        
        let transform = CGAffineTransform(translationX: deltaX, y: deltaY)
        
        handle.apply(transform)
        
        //image.image = resizeUIImage(image: image.image, targetSize: newSize) ?? image.image
        
        var newOrigin = CGPoint(x:handle.frame.origin.x + 5, y:handle.frame.origin.y + 5)
        
        for handle in handles{
            if handle.frame.origin.x < newOrigin.x && handle.frame.origin.y < newOrigin.y {
                newOrigin = CGPoint(x:handle.frame.origin.x + 5, y:handle.frame.origin.y + 5)
            }
        }
        if let image = image{
            let translationTransform = CGAffineTransform(translationX: -anchorForTranslation.x, y: -anchorForTranslation.y)
            let scaleTrasfrom = CGAffineTransform(scaleX: newSize.width/image.renderRect.width, y: newSize.height/image.renderRect.height)
            let invertedDranslationTransform = CGAffineTransform(translationX: anchorForTranslation.x, y: anchorForTranslation.y)

//            image.renderRect.origin = newOrigin
//            image.renderRect.size = newSize
//
//            image.renderRect = image.renderRect.applying(translationTransform)
//            image.renderRect = image.renderRect.applying(scaleTrasfrom)
//            image.renderRect = image.renderRect.applying(invertedDranslationTransform)

//            image.image = UIImage()
//
            image.applyDuringHandle(translationTransform)
            image.applyDuringHandle(scaleTrasfrom)
            image.applyDuringHandle(invertedDranslationTransform)
        }
        
        sender?.setNeedsDisplay()
    }
    
    func resizeUIImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(targetSize)
        image.draw(in: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func unBind(){
        for handle in handles {
            handle.removeFromSuperview()
        }
    }
}

class Handle: UIView{
    
    var modifier: ImageModifier?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /// Public init(coder:) implementation
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        self.isUserInteractionEnabled = true
        self.backgroundColor = .white
        self.layer.borderWidth = 2.0
        self.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func apply(_ transform: CGAffineTransform){
        self.transform = self.transform.concatenating(transform)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            modifier?.resize(sender: self, position: touch.location(in: modifier?.getContext()), previousPosition: touch.previousLocation(in: modifier?.getContext()))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
