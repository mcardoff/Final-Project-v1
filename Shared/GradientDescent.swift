//
//  GradientDescent.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 5/4/22.
//

import Foundation

class GradientDescent: OptimizationMethod {
    var learningRate : Double
    
    init(_ rate: Double) {
        learningRate = rate // determines by how much you should descend
    }
    func minimize(problem: inout Problem, endCriteria: EndCriteria) -> EndCriteriaType {
        // get current problem
        var ecType = EndCriteriaType.None
        return ecType
    }
}
