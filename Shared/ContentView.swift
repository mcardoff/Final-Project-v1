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
    @State var trackVal : TrackType = .leftHander
    @State var track : Track = Track(track: .leftHander, KMAX: 0.125, TRACKWIDTH: 1.0)
    @State var xs : [Double] = []
    @State var ys : [Double] = []
    @State var learningRate : Double = 0.1
    @State var onTrackWt : Double = 0.0
    @State var costWt : Double = 0.5
    @State var kmaxWt : Double = 0.0
    @State var fricWt : Double = 0.25
    @State var ccvWt : Double = 0.0
    @State var dsWt : Double = 0.0
    @State var numIter : Double = 1.0
    
    @State private var isEditing = false
    
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
                        Text("Track")
                        Picker("", selection: $trackVal) {
                            ForEach(TrackType.allCases) {
                                item in Text(item.toString())
                            }
                        }.frame(width: 150.0)
                    }//.padding()
                    VStack {
                        HStack{
                            Text("Gradient Descent LR: ")
                            Text(String(format: "%0.2f", learningRate)).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $learningRate,
                            in: 0...1, step: 0.01,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
                    }//.padding()
                    VStack {
                        HStack{
                            Text("Time Cost WF: ")
                            Text(String(format: "%0.2f", costWt)).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $costWt,
                            in: 0...1, step: 0.01,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
//                        Text("Time Cost Weight Factor")
//                        TextField("Time Cost Weight Factor", value: $costWt, formatter: doubleFormatter)
//                            .frame(width: 100.0)
                    }//.padding()
                    VStack {
                        HStack{
                            Text("KMax WF: ")
                            Text(String(format: "%0.2f", kmaxWt)).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $kmaxWt,
                            in: 0...1, step: 0.01,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
//                        Text("Max Curvature Weight Factor")
//                        TextField("Max Curvature Weight Factor", value: $kmaxWt, formatter: doubleFormatter)
//                            .frame(width: 100.0)
                    }//.padding()
                    VStack {
                        HStack{
                            Text("Max Friction WF: ")
                            Text(String(format: "%0.2f", fricWt)).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $fricWt,
                            in: 0...1, step: 0.01,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
//                        Text("Max Friction Weight Factor")
//                        TextField("Max Friction Weight Factor", value: $fricWt, formatter: doubleFormatter)
//                            .frame(width: 100.0)
                    }//.padding()
                    VStack {
                        HStack{
                            Text("Center Curvature WF: ")
                            Text(String(format: "%0.2f", ccvWt)).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $ccvWt,
                            in: 0...1, step: 0.01,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
//                        Text("Center Curvature Weight Factor")
//                        TextField("Center Curvature Weight Factor", value: $ccvWt, formatter: doubleFormatter)
//                            .frame(width: 100.0)
                    }//.padding()
                    /*VStack {
                        HStack{
                            Text("ds WF: ")
                            Text(String(format: "%0.2f", dsWt)).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $dsWt,
                            in: 0...1, step: 0.01,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
                    }//.padding()*/
                    /*VStack {
                        HStack{
                            Text("On Track WF: ")
                            Text(String(format: "%0.2f", onTrackWt)).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $onTrackWt,
                            in: 0...1, step: 0.01,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
                    }//.padding()*/
                    VStack {
                        HStack{
                            Text("Generations of Gradient Descent: ")
                            Text(String(format: "%d", Int(numIter))).foregroundColor(isEditing ? .red : .blue)
                        }
                        Slider(
                            value: $numIter,
                            in: 1...10,
                            step: 1,
                            onEditingChanged: { editing in isEditing = editing }
                        ).frame(width: 100.0)
                    }.padding()
                }
                TabView {
                    drawingView(xs: $xs, ys: $ys, trackObj: $track)
                        .padding()
                        .aspectRatio(1, contentMode: .fit)
                        .drawingGroup()
                        .tabItem {
                            Text("Track Plot")
                        }
                    TextEditor(text: $text)
                        .tabItem {
                            Text("Change in Path")
                        }
                }
            }
            HStack {
            Button("Calculate GD", action: self.calculate)
                .padding()
            Button("Clear RL", action: self.clear)
                .padding()
            }
        }
    }
    
    func calculate() {
        track = Track(track: trackVal, KMAX: 0.125, TRACKWIDTH: 1.0)
        
//        print(track.ycs)
        let endCriteria = EndCriteria(maxIterations: Int(numIter), maxStationaryStateIterations: Int(numIter), rootEpsilon: 1.0e-8, functionEpsilon: 1.0e-9, gradientNormEpsilon: 1.0e-5)
        let costFunc = timeCostFunction()
        let constraint = RacingLineConstraints(track: track)
        let initialXValue = track.xcs, initialYValue = track.ycs
        var problem = RacingLineProblem(costFunction: costFunc, constraint: constraint, initialXValues: initialXValue, initialYValues: initialYValue)
        let solver = GradientDescent(learningRate, costWt, kmaxWt, fricWt, ccvWt, dsWt, onTrackWt)
        _ = solver.minimize(problem: &problem, endCriteria: endCriteria)

        xs = problem.currentXValues
        ys = problem.currentYValues

        for i in 0..<xs.count-1 {
            let dx = xs[i]-xs[i+1], dy = ys[i]-ys[i+1], ds = sqrt(dx*dx+dy*dy)
            text += ("\(i): \n")
            text += ("dx: \(dx) dy: \(dy) ds: \(ds)\n\n")
        }
    }
    
    func clear() {
        xs.removeAll()
        ys.removeAll()
        text = ""
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
