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
            drawingView(optObj: $optimizationObj)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
            
            Button("Calculate Stuff", action: self.calculate)
                .padding()
            
        }
    }
    
    func calculate() {
        for i in 0..<150 {
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
