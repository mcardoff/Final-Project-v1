//
//  TrackProblem.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 5/4/22.
//

import Foundation
import LASwift

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
