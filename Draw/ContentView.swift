//
//  ContentView.swift
//  Draw
//
//  Created by Leonardo Sinibaldi on 15/05/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var cvc = CVContainer()
    
    var body: some View {
        NavigationView{
            ZStack{
                DrawView(cvContainer: $cvc).modifier(AspectRatioModifier(aspectRatio: 1.5))
            }
            .padding(10)
            .navigationBarItems(
                leading: HStack{
                    Button {
                        cvc.canvasView.tool = Pen(width: 5, color: .black)
                    }label:{
                        Image(systemName: "pencil")
                    }
                    Button {
                        cvc.canvasView.tool = EraserVec(width: 10)
                        
                    } label: {
                        Image(systemName: "eraser")
                    }
                    
                    Button {
                        cvc.canvasView.tool = EraserBit(width: 10)
                        
                    } label: {
                        Image(systemName: "eraser")
                    }
                    Button {
                        cvc.canvasView.tool = Lasso()
                        
                    } label: {
                        Image(systemName: "lasso")
                    }
                    Button {
                        for stroke in cvc.canvasView.drawing.strokes{
                            let transform = CGAffineTransform(translationX: 10, y: 10)
                            stroke.transform = stroke.transform.concatenating(transform)
                            stroke.path.apply(transform)
                            
                            cvc.canvasView.setNeedsDisplay()
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
