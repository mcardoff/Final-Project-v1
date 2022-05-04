//
//  ContentView.swift
//  Shared
//
//  Created by Michael Cardiff on 4/4/22.
//

import SwiftUI
import LASwift

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
        var endCriteria = EndCriteria(maxIterations: 1000, maxStationaryStateIterations: 100, rootEpsilon: 1.0e-8, functionEpsilon: 1.0e-9, gradientNormEpsilon: 1.0e-5)
        var costFunc = timeCostFunction()
        var constraint = NoConstraint()
        var initialValue = Matrix(Array(repeating: 1.0, count:1))
        var problem = Problem(costFunction: costFunc, constraint: constraint, initialValue: initialValue)
        var solver = LineSearchBasedMethod(lineSearch: ArmijoLineSearch())
        var solved = solver.minimize(problem: &problem, endCriteria: endCriteria)
        print(problem.currentValue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
