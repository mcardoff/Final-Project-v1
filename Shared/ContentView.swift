//
//  ContentView.swift
//  Shared
//
//  Created by Michael Cardiff on 4/4/22.
//

import SwiftUI

struct ContentView: View {
    
    @State var text : String = ""
    @State var optimizationObj = OptimizationOfPath()
    
    var body: some View {
        VStack{
            TabView {
                drawingView(optObj: $optimizationObj)
                    .padding()
                    .aspectRatio(1, contentMode: .fit)
                    .drawingGroup()
                    .tabItem {
                        Text("Track Plot")
                    }
                TextEditor(text: $text)
                    .tabItem {
                        Text("Curvature Vals")
                    }
            }
            Button("Calculate Stuff", action: self.calculate)
                .padding()
            
        }
    }
    
    func calculate() {
        testTrace()
        text = optimizationObj.ensureConstraints()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
