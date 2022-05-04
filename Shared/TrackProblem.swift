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
    
    override func costValue(params: Matrix) -> Double {
        // structure of parameters:
        // [x0,y0,x1,y1...]
        var costVal = 0.0
        let (xs,ys) = paramtoxy(parameters: params)
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
    
    func curvatureVal(xs: [Double], ys: [Double], i: Int) -> Double {
        let dxb = xs[i]-xs[i-1],
            dyb = ys[i]-ys[i-1],
            dsb = sqrt(dxb*dxb + dyb*dyb),
            dxf = xs[i+1]-xs[i],
            dyf = ys[i+1]-ys[i],
            dsf = sqrt(dxf*dxf + dyf*dyf),
            termOne = (dxb/dsb + dxf/dsf) * (dyf/dsf - dyb/dsb)/(dsf + dsb),
            termTwo = (dyb/dsb + dyf/dsf) * (dxf/dsf - dxb/dsb)/(dsf + dsb)
        
        return termOne-termTwo
    }
    
    func kmaxConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        let kval = curvatureVal(xs: xs, ys: ys, i: i)
        return kval <= self.KMAX
    }
    
    func onTrackConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        let offsetX = xs[i] - self.xcs[i],
            offsetY = ys[i] - self.ycs[i],
            dist = offsetX*offsetX + offsetY*offsetY
        return dist < 0.25 * self.TRACKWIDTH * self.TRACKWIDTH
        
    }
    
    func curvatureCenterConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        let offsetX = xs[i] - self.xcs[i],
            offsetY = ys[i] - self.ycs[i],
            curvature = curvatureVal(xs: xs, ys: ys, i: i)
        return abs(offsetX + curvature * offsetY) <= 1.0e-5
    }
    
    func frictionConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        let k = curvatureVal(xs: xs, ys: ys, i: i),
            mug = 9.8,
            v = sqrt(k / mug)
        return k * v * v - mug <= 1.0e-5
    }
    
    func dsConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        // ensure the car isn't warping to different points on the track
        let dx = xs[i] - xs[i-1],
            dy = ys[i] - ys[i-1],
            ds = dx*dx + dy*dy
        return ds < 1.0 // arbitrary for now
    }
    
    override func test(parameters: Matrix) -> Bool {
        let (xs,ys) = paramtoxy(parameters: parameters)
        for i in 1..<(parameters.rows-1) {
            if (!kmaxConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!onTrackConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!curvatureCenterConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!frictionConstraint(xs: xs, ys: ys, i: i)) { return false }
        }
        return true
    }
}

// helper funcs
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

func paramtoxy(parameters: Matrix) -> ([Double], [Double]){
    var xs : [Double] = [], ys : [Double] = []
    // easier to work with xs and ys than a parameter matrix
    for i in 0..<parameters.flat.count {
        if i % 2 == 0 { xs.append(parameters[i]) }
        else { ys.append(parameters[i]) }
    }
    return (xs,ys)
}
