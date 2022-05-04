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

class RacingLineConstraints : Constraint {
    
    let xcs : [Double], ycs : [Double]
    let KMAX = 0.5,
        TRACKWIDTH = 1.50
    
    override init() {
        var thetavals : [Double] = [], n = 150
        for i in 0..<n { thetavals.append(Double(i) * Double.pi / (2.0 * Double(n))) }
        
        let rad = 1.1
        xcs = thetavals.map {(theta: Double) -> Double in return rad*cos(theta)}
        ycs = thetavals.map {(theta: Double) -> Double in return rad*sin(theta)}
    }
    
    func curvatureVal(i: Int, param: Matrix) -> Double {
        let dxb = param[i]-param[i-1],
            dyb = param[param.cols+i]-param[param.cols+i-1],
            dsb = sqrt(dxb*dxb + dyb*dyb),
            dxf = param[i+1]-param[i],
            dyf = param[param.cols+i+1]-param[param.cols+i],
            dsf = sqrt(dxf*dxf + dyf*dyf),
            termOne = (dxb/dsb + dxf/dsf) * (dyf/dsf - dyb/dsb)/(dsf + dsb),
            termTwo = (dyb/dsb + dyf/dsf) * (dxf/dsf - dxb/dsb)/(dsf + dsb)
        
        return termOne-termTwo
    }
    
    func kmaxConstraint(i: Int, param: Matrix) -> Bool {
        let kval = curvatureVal(i: i, param: param)
        return kval <= self.KMAX
    }
    
    func onTrackConstraint(i: Int, param: Matrix) -> Bool {
        let offsetX = param[i] - self.xcs[i],
            offsetY = param[param.cols+i] - self.ycs[i],
            dist = offsetX*offsetX + offsetY*offsetY
        return dist < 0.25 * self.TRACKWIDTH * self.TRACKWIDTH
        
    }
    
    func curvatureCenterConstraint(i: Int, param: Matrix) -> Bool {
        let offsetX = param[i] - self.xcs[i],
            offsetY = param[param.cols+i] - self.ycs[i],
            curvature = curvatureVal(i: i, param: param)
        return abs(offsetX + curvature * offsetY) <= 1.0e-5
    }
    
    func frictionConstraint(i: Int, param: Matrix) -> Bool {
        let k = curvatureVal(i: i, param: param),
            mug = 9.8,
            v = sqrt(k / mug)
        return k * v * v - mug <= 1.0e-5
    }
    
    override func test(parameters: Matrix) -> Bool {
        for i in 1..<(parameters.rows-1) {
            // hopefully the structure is [[x, x, x, ...]
            //                             [y, y, y, ...]],
            if (!kmaxConstraint(i: i, param: parameters)) { return false }
            if (!onTrackConstraint(i: i, param: parameters)) { return false }
            if (!curvatureCenterConstraint(i: i, param: parameters)) { return false }
            if (!frictionConstraint(i: i, param: parameters)) { return false }
        }
        return true
    }
}
