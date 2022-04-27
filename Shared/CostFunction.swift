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
    
    // define how to take the gradient!
    func gradient(parameters : Matrix) -> Matrix {
        var fp : Double, fm : Double
        var params = parameters
        let paramcount = parameters.cols * parameters.rows
        var grad = Matrix(params.rows,params.cols)
        
        for i in 0..<paramcount {
            params[i] += finiteDiff
            fp = costValue(params: params)
            params[i] -= 2.0 * finiteDiff
            fm = costValue(params: params)
            grad[i] = 0.5 * (fp - fm) / finiteDiff
            params[i] = parameters[i]
        }
        return grad
    }
    
}
