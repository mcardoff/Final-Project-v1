//
//  TrackProblem.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 5/4/22.
//

import Foundation
import LASwift

// use overwritten init in problem formulation
class RacingLineProblem {
    var costFunction : timeCostFunction
    var constraint : RacingLineConstraints
    var currentXValues : [Double]
    var currentYValues : [Double]
    
    var functionValue = 0.0
    var squaredNorm = 0.0
    var functionEvaluation = 0
    var gradientEvaluation = 0
    
    init(costFunction : timeCostFunction, constraint : RacingLineConstraints, initialXValues : [Double], initialYValues : [Double]) {
        self.costFunction = costFunction
        self.constraint = constraint
        self.currentXValues = initialXValues
        self.currentYValues = initialYValues
    }
    
    func reset() {
        functionEvaluation = 0
        gradientEvaluation = 0
        functionValue = 0.0
        squaredNorm = 0.0
    }
    
    func value(xs: [Double], ys: [Double]) -> Double {
        functionEvaluation += 1
        return costFunction.costValue(xs: xs, ys: ys)
    }
    
    func gradient(gradx : inout [Double], grady : inout [Double], xs: [Double], ys: [Double]) {
        gradientEvaluation += 1
        costFunction.gradient(gradx: &gradx, grady: &grady, xs: xs, ys: ys)
    }
    
    func valueAndGradient(gradx : inout [Double], grady : inout [Double], xs: [Double], ys: [Double]) -> Double {
        functionEvaluation += 1
        gradientEvaluation += 1
        return costFunction.valueAndGradient(gradx: &gradx, grady: &grady, xs: xs, ys: ys)
    }
}

class timeCostFunction : CostFunction {
//    var N: Int = 150 // this many steps around the circuit
    
    func costValue(xs: [Double], ys: [Double]) -> Double {
        // structure of parameters:
        // [x0,y0,x1,y1...]
        var costVal = 0.0
        for i in 1..<xs.count-1 {
            let k = curvatureVal(xs: xs, ys: ys, i: i),
                dx = xs[i]-xs[i-1],
                dy = ys[i]-ys[i-1],
                ds = sqrt(dx*dx+dy*dy)
            costVal += sqrt(abs(k))*ds
        }
        return costVal
    }
    
    func gradient(gradx: inout [Double], grady: inout [Double], xs: [Double], ys: [Double]){
        var fp : Double, fm : Double
        var tempparams = xs, tempxs = xs, tempys = ys
        tempparams.append(contentsOf: ys)
        let copy = tempparams
        
        for i in 0..<tempparams.count {
            tempparams[i] += finiteDiff
            if 0 <= i && i < xs.count { tempxs[i] += finiteDiff /* perturb only x */ }
            else { tempys[i-xs.count] += finiteDiff }
            fp = costValue(xs: tempxs, ys: tempys)
            tempparams[i] -= 2.0*finiteDiff
            if 0 <= i && i < xs.count { tempxs[i] -= 2.0*finiteDiff /* perturb only x */ }
            else { tempys[i-xs.count] -= 2.0*finiteDiff }
            fm = costValue(xs: tempxs, ys: tempys)
            let gradval = 0.5 * (fp - fm) / finiteDiff
            if 0 <= i && i < xs.count { gradx[i] = gradval }
            else { grady[i-xs.count] = gradval }
//            grad[i] = 0.5 * (fp - fm) / finiteDiff
            tempparams[i] = copy[i]
            tempxs = xs
            tempys = ys
        }
    }
    
    func valueAndGradient(gradx: inout [Double], grady: inout [Double], xs: [Double], ys: [Double]) -> Double {
        self.gradient(gradx: &gradx, grady: &grady, xs: xs, ys: ys)
        return costValue(xs: xs, ys: ys)
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
    
    func test(xs: [Double], ys: [Double]) -> Bool {
//        let (xs,ys) = paramtoxy(parameters: parameters)
        for i in 1..<(xs.count-1) {
            if (!kmaxConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!onTrackConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!curvatureCenterConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!frictionConstraint(xs: xs, ys: ys, i: i)) { return false }
        }
        return true
    }
}

class RacingEndCriteria : EndCriteria {
    
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
