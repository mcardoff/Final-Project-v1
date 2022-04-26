//
//  Optimizer.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/8/22.
//

import Foundation


class OptimizationOfPath {
    
    let track = Track(), VMAX = 100.0
    var xs : [Double], ys : [Double] // a path along track
    
    
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
    
    init() {
        // inner circle track
        var thetavals : [Double] = [], n = 150
        for i in 0..<n/2 { thetavals.append(Double(i) * Double.pi / (2.0 * Double(n))) }
        let dx = 0.01
        
        xs = thetavals.map {(theta: Double) -> Double in return 1.0*cos(theta)}
        ys = thetavals.map {(theta: Double) -> Double in return 1.0*sin(theta)}
        for _ in n/2...n {
            xs.append(xs.last! - dx)
            ys.append(ys.last!)
        }
    }
    
    func ensureConstraints() -> String {
        var retStr = ""
        for i in 1..<xs.count-1 {
            retStr += "\(i): "
            let k = curvatureVal(i: i), v = calculateVelocity(i: i)
            if (!kmaxConstraint(i: i)) { retStr += "k>kMAX!!!! " }
            if (!onTrackConstraint(i: i)) { retStr += "Off track!!!! " }
            if (!curvatureCenterConstraint(i: i)) { retStr += "Weird one not satisfied " }
            if (k * v * v - track.FRICTION * track.GRAVITY > 0) { retStr += "FRICTION BAD" }
            retStr += "\n"
        }
        retStr += calculateTimeCost()
        return retStr
    }
    
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
    
    func calculateVelocity(i: Int) -> Double {
        let k = curvatureVal(i: i),
        mug = track.GRAVITY*track.FRICTION
        return sqrt(k / mug)
    }
    
    func kmaxConstraint(i: Int) -> Bool {
        let kval = curvatureVal(i: i)
        return kval <= track.KMAX
    }
    
    func onTrackConstraint(i: Int) -> Bool {
        let offsetX = xs[i] - track.xcs[i],
            offsetY = ys[i] - track.ycs[i],
            dist = offsetX*offsetX + offsetY*offsetY
        return dist < 0.25 * track.TRACKWIDTH * track.TRACKWIDTH
        
    }
    
    func curvatureCenterConstraint(i: Int) -> Bool {
        let offsetX = xs[i] - track.xcs[i],
            offsetY = ys[i] - track.ycs[i],
            curvature = curvatureVal(i: i)
        return abs(offsetX + curvature * offsetY) <= 1.0e-5
    }
    
    func calculateTimeCost() -> String {
        //        _
        //       /   1          __     1
        // t =   |  --- ds  =  \     ---- Δs
        //      _/   v         /__   v[i]
        //                      i
        var costVal = 0.0
        for i in 1..<xs.count-1 {
            let k = curvatureVal(i: i),
                dx = xs[i]-xs[i-1],
                dy = ys[i]-ys[i-1],
                ds = sqrt(dx*dx+dy*dy)
            costVal += sqrt(abs(k))*ds
        }
        return String("cost: \(costVal)\n")
    }
}
