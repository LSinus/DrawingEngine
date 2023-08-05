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
                DrawView(cvContainer: $cvc)
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
                        cvc.canvasView.tool = Marker(width: 30, color: .yellow)
                    }label:{
                        Image(systemName: "highlighter")
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
