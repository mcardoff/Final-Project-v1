//
//  GradientDescent.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 5/4/22.
//

import Foundation

class GradientDescent {
    var learningRate : Double
    
    init(_ rate: Double) {
        learningRate = rate // determines by how much you should descend
    }
    func minimize(problem: inout RacingLineProblem, endCriteria: EndCriteria) -> EndCriteriaType {
        // get current problem
        var ecType = EndCriteriaType.None
        var done = false
        var iterationNumber_ = 0,
            maxStationaryStateIterations_ = endCriteria.maxStationaryStateIterations,
            xGrad = Array(repeating: 0.0, count: problem.currentXValues.count),
            yGrad = Array(repeating: 0.0, count: problem.currentYValues.count)
        
        var xs = problem.currentXValues, ys = problem.currentYValues
//        repeat {
//            problem.currentXValues should update according to gradient
            problem.costFunction.gradient(gradx: &xGrad, grady: &yGrad, xs: xs, ys: ys, constraint: problem.constraint)
            // x values change account to xgrad, y values change according to ygrad
            for i in 1..<xs.count-1 {
//                print("xg: \(xGrad[i]), yg: \(yGrad[i])")
                xs[i] -= learningRate * xGrad[i]
                ys[i] -= learningRate * yGrad[i]
                // clip values, they cannot 
            }
            
            problem.currentXValues = xs
            problem.currentYValues = ys
            
            if(endCriteria.checkMaxIterations(iteration: iterationNumber_, endCriteriaType: &ecType)) {
                endCriteria.checkStationaryFunctionValue(fxOld: 0.0, fxNew: 0.0, stationaryStateIterations: &maxStationaryStateIterations_, endCriteriaType: &ecType);
                endCriteria.checkMaxIterations(iteration: iterationNumber_, endCriteriaType: &ecType)
                
                return ecType
            }
            
            
            iterationNumber_ += 1
            if iterationNumber_ > endCriteria.maxIterations {
                done = true
//                break
            }
//        } while(!done)
        return ecType
    }
}
