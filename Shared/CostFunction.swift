//
//  CostFunction.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/26/22.
//

import Foundation
import LASwift

class CostFunction {
    
    let finiteDiff = 1.0e-8
    
    func costValue(params: Matrix) -> Double {
        return 1.0e10 // should be overwritten in subclass
    }
    
    func costValues(parameters : Matrix) -> Matrix {
        return Matrix(Array(repeating: 0.0, count: 0))
    }
    
    // define how to take the gradient!
    func gradient(grad: inout Matrix, parameters : Matrix){
        var fp : Double, fm : Double
        var tempparams = parameters
        let paramcount = parameters.cols * parameters.rows
        
        for i in 0..<paramcount {
            tempparams[i] += finiteDiff
            fp = costValue(params: parameters)
            tempparams[i] -= 2.0 * finiteDiff
            fm = costValue(params: parameters)
            grad[i] = 0.5 * (fp - fm) / finiteDiff
            tempparams[i] = parameters[i]
        }
    }
    
    func valueAndGradient(grad : inout Matrix, parameters : Matrix) -> Double {
        gradient(grad: &grad, parameters: parameters)
        return costValue(params: parameters)
    }
}


// example, simple function, minimum should be 0
class testCostFunction : CostFunction {
    override func costValue(params: Matrix) -> Double {
        return params[0] * params[0]
    }
}
