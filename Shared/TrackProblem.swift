//
//  TrackProblem.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 5/4/22.
//

import Foundation
import LASwift

// use overwritten init in problem formulation
class RacingLineProblem {
    var constraint : RacingLineConstraints
    var costFunction : timeCostFunction
    var currentXValues : [Double]
    var currentYValues : [Double]
    
    var functionValue = 0.0
    var squaredNorm = 0.0
    var functionEvaluation = 0
    var gradientEvaluation = 0
    
    init(costFunction : timeCostFunction, constraint : RacingLineConstraints, initialXValues : [Double], initialYValues : [Double]) {
        self.costFunction = costFunction
        self.constraint = constraint
        self.currentXValues = initialXValues
        self.currentYValues = initialYValues
    }
    
    func reset() {
        functionEvaluation = 0
        gradientEvaluation = 0
        functionValue = 0.0
        squaredNorm = 0.0
    }
    
    func value(xs: [Double], ys: [Double]) -> Double {
        functionEvaluation += 1
        return costFunction.costValue(xs: xs, ys: ys, constraint: constraint)
    }
}


