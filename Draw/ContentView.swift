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
                        SelectionMenuView.selectionMenu.resetMenu()
                        cvc.canvasView.drawing.removeLassoStrokes()
                        cvc.canvasView.setNeedsDisplay()
                        cvc.canvasView.tool = Pen(width: 5, color: .black)
                    }label:{
                        Image(systemName: "pencil")
                    }
                    Button {
                        SelectionMenuView.selectionMenu.resetMenu()
                        cvc.canvasView.drawing.removeLassoStrokes()
                        cvc.canvasView.setNeedsDisplay()
                        cvc.canvasView.tool = Marker(width: 30, color: .yellow)
                    }label:{
                        Image(systemName: "highlighter")
                    }
                    Button {
                        SelectionMenuView.selectionMenu.resetMenu()
                        cvc.canvasView.drawing.removeLassoStrokes()
                        cvc.canvasView.setNeedsDisplay()
                        cvc.canvasView.tool = EraserVec(width: 10)
                        
                    } label: {
                        Image(systemName: "eraser")
                    }
                    
                    Button {
                        SelectionMenuView.selectionMenu.resetMenu()
                        cvc.canvasView.drawing.removeLassoStrokes()
                        cvc.canvasView.setNeedsDisplay()
                        cvc.canvasView.tool = EraserBit(width: 10)
                        
                    } label: {
                        Image(systemName: "eraser")
                    }
                    Button {
                        SelectionMenuView.selectionMenu.resetMenu()
                        cvc.canvasView.drawing.removeLassoStrokes()
                        cvc.canvasView.setNeedsDisplay()
                        cvc.canvasView.tool = Lasso(SelectingState())
                        
                    } label: {
                        Image(systemName: "lasso")
                    }
                    
                },
                trailing: HStack{
                    Button {
                        UndoManager.undoManager.undo()
                        
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    Button {
                        UndoManager.undoManager.redo()
                        
                    } label: {
                        Image(systemName: "arrow.uturn.forward")
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
