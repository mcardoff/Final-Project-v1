//
//  Optimizer.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/8/22.
//

import Foundation


class OptimizationOfPath {
    var KMAX : Double, TRACKWIDTH : Double
    var xs : [Double], ys : [Double]
    var xcs : [Double], ycs : [Double]
    var xits : [Double], yits : [Double]
    var xots : [Double], yots : [Double]
//    var curvatureVals
    
    init() {
        // do basic one as an example
        KMAX = 0.5
        TRACKWIDTH = 1.50
        var thetavals : [Double] = [], n = 150
        for i in 0..<n { thetavals.append(Double(i) * Double.pi / (2.0 * Double(n))) }
        xs = thetavals.map {(theta: Double) -> Double in return 1.0*cos(theta)}
        ys = thetavals.map {(theta: Double) -> Double in return 1.0*sin(theta)}
        
        xcs = thetavals.map {(theta: Double) -> Double in return 1.1*cos(theta)}
        ycs = thetavals.map {(theta: Double) -> Double in return 1.1*sin(theta)}
        
        xits = thetavals.map {(theta: Double) -> Double in return (1.1-0.2)*cos(theta)}
        yits = thetavals.map {(theta: Double) -> Double in return (1.1-0.2)*sin(theta)}
        
        xots = thetavals.map {(theta: Double) -> Double in return (1.1+0.2)*cos(theta)}
        yots = thetavals.map {(theta: Double) -> Double in return (1.1+0.2)*sin(theta)}
    }
    
//    init(kmax: Double, trackwidth: Double, xs: [Double], ys: [Double]) {
//        if(kmax > 0.0) {
//            KMAX = kmax
//        } else {
//            KMAX = 0.5
//        }
//        
//        if(trackwidth > 0.0) {
//            TRACKWIDTH = trackwidth
//        } else {
//            TRACKWIDTH = 150.0
//        }
//        self.xs = xs
//        self.ys = ys
//    }
    
    func curvatureVal(i: Int) -> Double {
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
    
    func kmaxConstraint(i: Int) -> Bool {
        let kval = curvatureVal(i: i)
        return kval <= KMAX
    }
    
    func onTrackConstraint(i: Int, xcs: [Double], ycs: [Double]) -> Bool {
        let offsetX = xs[i] - xcs[i],
            offsetY = ys[i] - ycs[i],
            dist = sqrt(offsetX*offsetX + offsetY*offsetY)
        return dist < 0.5 * TRACKWIDTH
        
    }
}
