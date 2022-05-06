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
    @State var xs : [Double] = []
    @State var ys : [Double] = []
    
    var body: some View {
        VStack{
            TabView {
                drawingView(xs: $xs, ys: $ys, optObj: $optimizationObj)
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
        let track = Track()
        
        var endCriteria = EndCriteria(maxIterations: 1, maxStationaryStateIterations: 10, rootEpsilon: 1.0e-8, functionEpsilon: 1.0e-9, gradientNormEpsilon: 1.0e-5)
        var costFunc = timeCostFunction()
        var constraint = RacingLineConstraints()
        var initialXValue = track.xcs, initialYValue = track.ycs
        var problem = RacingLineProblem(costFunction: costFunc, constraint: constraint, initialXValues: initialXValue, initialYValues: initialYValue)
        var solver = GradientDescent(0.01)
        var solved = solver.minimize(problem: &problem, endCriteria: endCriteria)
//        print(problem.currentXValues)
//        print(problem.currentXValues)
        
//        for (o,e) in zip(initialYValue, problem.currentYValues) {
//            print(o-e)
//        }
        xs = problem.currentXValues
        ys = problem.currentYValues
        
        for i in 0..<xs.count {
            let tup = (xs[i], ys[i]), tup1 = (initialXValue[i], initialYValue[i])
            print("\(i)\nold: \(tup1)\nnew: \(tup)\n\n")
        }
        
//        for tup in zip(track.xis,track.yis) {
//            print(tup)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
