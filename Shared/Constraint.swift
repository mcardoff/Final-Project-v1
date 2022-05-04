//
//  Constraint.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/26/22.
//

import Foundation
import LASwift

class Constraint {
    // should be overwrittem
    func test(parameters: Matrix) -> Bool {
        return true
    }
    
    func update(parameters: inout Matrix, direction: Matrix, beta: Double) -> Double {
        var difference = beta,
            newparams = parameters,
            valid = test(parameters: parameters),
            icount = 0
        // adjust parameters
        for i in 0..<(parameters.rows*parameters.cols) {
            newparams[i] += difference * direction[i]
        }
        
        while(!valid) {
            assert(icount <= 200, "#Can't update parameter vector!")
            difference *= 0.5
            icount += 1
            for i in 0..<(parameters.rows*parameters.cols) {
                newparams[i] = parameters[i] + difference * direction[i]
            }
            valid = test(parameters: newparams)
        }
        
        for i in 0..<(parameters.rows*parameters.cols) {
            parameters[i] = parameters[i] + difference * direction[i]
        }
        return difference
    }
}

class NoConstraint : Constraint {
    override func test(parameters: Matrix) -> Bool {
        return true
    }
}

