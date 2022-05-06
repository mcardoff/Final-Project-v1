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
    @State var learningRate : Double = 10.0
    @State var onTrackWt : Double = 0.1
    @State var costWt : Double = 0.1
    @State var kmaxWt : Double = 0.1
    @State var fricWt : Double = 0.1
    @State var ccvWt : Double = 0.1
    @State var dsWt : Double = 0.1
    @State var numIter : Int = 1
    
    private var intFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()
    
    private var doubleFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.minimumSignificantDigits = 3
        f.maximumSignificantDigits = 9
        return f
    }()
    
    var body: some View {
        VStack{
            HStack{
                VStack {
                    VStack {
                        Text("Gradient Descent Learning Rate")
                        TextField("Gradient Descent Learning Rate", value: $learningRate, formatter: doubleFormatter)
                            .frame(width: 100.0)
                    }.padding()
                    VStack {
                        Text("Time Cost Weight Factor")
                        TextField("Time Cost Weight Factor", value: $costWt, formatter: doubleFormatter)
                            .frame(width: 100.0)
                    }.padding()
                    VStack {
                        Text("Max Curvature Weight Factor")
                        TextField("Max Curvature Weight Factor", value: $kmaxWt, formatter: doubleFormatter)
                            .frame(width: 100.0)
                    }.padding()
                    VStack {
                        Text("Max Friction Weight Factor")
                        TextField("Max Friction Weight Factor", value: $fricWt, formatter: doubleFormatter)
                            .frame(width: 100.0)
                    }.padding()
                    VStack {
                        Text("Center Curvature Weight Factor")
                        TextField("Center Curvature Weight Factor", value: $ccvWt, formatter: doubleFormatter)
                            .frame(width: 100.0)
                    }.padding()
                    VStack {
                        Text("Arc Length Weight Factor")
                        TextField("Arc Length Weight Factor", value: $dsWt, formatter: doubleFormatter)
                            .frame(width: 100.0)
                    }.padding()
                    VStack {
                        Text("Track Limits Weight Factor")
                        TextField("Track Limits Weight Factor", value: $onTrackWt, formatter: doubleFormatter)
                            .frame(width: 100.0)
                    }.padding()
                }
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
            }
            Button("Calculate Stuff", action: self.calculate)
                .padding()
        }
    }
    
    func calculate() {
        let track = Track()
        
        let endCriteria = EndCriteria(maxIterations: 1, maxStationaryStateIterations: 10, rootEpsilon: 1.0e-8, functionEpsilon: 1.0e-9, gradientNormEpsilon: 1.0e-5)
        let costFunc = timeCostFunction()
        let constraint = RacingLineConstraints()
        let initialXValue = track.xcs, initialYValue = track.ycs
        var problem = RacingLineProblem(costFunction: costFunc, constraint: constraint, initialXValues: initialXValue, initialYValues: initialYValue)
        let solver = GradientDescent(learningRate, costWt, kmaxWt, fricWt, ccvWt, dsWt, onTrackWt)
        _ = solver.minimize(problem: &problem, endCriteria: endCriteria)
        
        xs = problem.currentXValues
        ys = problem.currentYValues
        
        for i in 0..<xs.count {
            let tup = (xs[i], ys[i]), tup1 = (initialXValue[i], initialYValue[i])
            print("\(i)\nold: \(tup1)\nnew: \(tup)\n\n")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
