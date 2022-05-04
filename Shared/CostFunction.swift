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

class timeCostFunction : CostFunction {
    var N: Int = 150 // this many steps around the circuit
    
    func curvatureVal(xs: [Double], ys: [Double], i: Int) -> Double {
        let dxb = xs[i]-xs[i-1],
            dyb = ys[i]-ys[i-1],
            dsb = sqrt(dxb*dxb + dyb*dyb),
            dxf = xs[i+1]-xs[i],
            dyf = ys[i+1]-xs[i],
            dsf = sqrt(dxf*dxf + dyf*dyf),
            termOne = (dxb/dsb + dxf/dsf) * (dyf/dsf - dyb/dsb)/(dsf + dsb),
            termTwo = (dyb/dsb + dyf/dsf) * (dxf/dsf - dxb/dsb)/(dsf + dsb)
        
        return termOne-termTwo
    }
    
    override func costValue(params: Matrix) -> Double {
        // structure of parameters:
        // [x0,y0,x1,y1...]
        var costVal = 0.0
        var xs : [Double] = [], ys : [Double] = []
        // easier to work with xs and ys than a parameter matrix
        for i in 0..<params.flat.count {
            if i % 2 == 0 { xs.append(params[i]) }
            else { ys.append(params[i]) }
        }
        for i in 1..<N-1 {
            let k = curvatureVal(xs: xs, ys: ys, i: i),
                dx = xs[i]-xs[i-1],
                dy = ys[i]-ys[i-1],
                ds = sqrt(dx*dx+dy*dy)
            costVal += sqrt(abs(k))*ds
        }
        return costVal
    }
}
