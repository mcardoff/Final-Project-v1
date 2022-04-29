//
//  Formulated Problem.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/29/22.
//

import Foundation
import LASwift

class Problem {
    
    var costFunction : CostFunction
    var constraint : Constraint
    var currentValue : Matrix
    
    var functionValue = 0.0
    var squaredNorm = 0.0
    var functionEvaluation = 0
    var gradientEvaluation = 0
    
    init(costFunction : CostFunction, constraint : Constraint, initialValue : Matrix) {
        self.costFunction = costFunction
        self.constraint = constraint
        self.currentValue = initialValue
    }
    
    func reset() {
        functionEvaluation = 0
        gradientEvaluation = 0
        functionValue = 0.0
        squaredNorm = 0.0
    }
    
    func value(parameters : Matrix) -> Double {
        functionEvaluation += 1
        return costFunction.costValue(params: parameters)
    }
    
    func values(parameters : Matrix) -> Matrix {
        functionEvaluation += 1
        return costFunction.costValues(parameters: parameters)
    }
    
    func gradient( grad : inout Matrix, parameters : Matrix) {
        gradientEvaluation += 1
        costFunction.gradient(grad: &grad, parameters: parameters)
    }
    
    func valueAndGradient( grad : inout Matrix, parameters : Matrix) -> Double {
        functionEvaluation += 1
        gradientEvaluation += 1
        return costFunction.valueAndGradient(grad: &grad, parameters: parameters)
    }
    
}
