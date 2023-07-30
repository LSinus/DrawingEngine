//
//  ContentView.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 15/05/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var canvasView = CanvasView()
    
    var body: some View {
        NavigationView{
            ZStack{
                DrawView(canvasView: $canvasView).modifier(AspectRatioModifier(aspectRatio: 1.5))
            }
            .padding(10)
            .navigationBarItems(
                leading: HStack{
                    Button {
                        canvasView.tool = Pen(width: 5, color: .black)
                    }label:{
                        Image(systemName: "pencil")
                    }
                    Button {
                        canvasView.tool = EraserVec(width: 10)
                        
                    } label: {
                        Image(systemName: "eraser")
                    }
                    
                    Button {
                        canvasView.tool = EraserBit(width: 10)
                        
                    } label: {
                        Image(systemName: "eraser")
                    }
                    Button {
                        canvasView.tool = Lasso()
                        
                    } label: {
                        Image(systemName: "lasso")
                    }
                    Button {
                        for stroke in canvasView.drawing.strokes{
                            let transform = CGAffineTransform(translationX: 10, y: 10)
                            stroke.transform = stroke.transform.concatenating(transform)
                            stroke.path.apply(transform)
                            
                            canvasView.setNeedsDisplay()
                        }
                        
                    } label: {
                        Image(systemName: "lasso")
                    }
                }
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}



struct AspectRatioModifier: ViewModifier {
    let aspectRatio: CGFloat

    func body(content: Content) -> some View {
        content.aspectRatio(aspectRatio, contentMode: .fit)
    }
}
