//
//  RacingLineConstraints.swift
//  Final Project V1 (iOS)
//
//  Created by Michael Cardiff on 5/5/22.
//

import Foundation

class RacingLineConstraints {
    
    var xcs : [Double], ycs : [Double]
    var xis : [Double], yis : [Double]
    let KMAX = 0.5,
        TRACKWIDTH = 1.50
    
    init() {
        var thetavals : [Double] = [], n = 150
        for i in 0..<n {
            thetavals.append(Double(i) * 2.0 * Double.pi / (2.0 * Double(n)))
        }
        
        xcs = []; ycs = []; xis = []; yis = []
        let rad = 1.0
        for i in 0..<50 {
            xcs.append(1+rad)
            xis.append(1+rad-TRACKWIDTH/2)
            ycs.append((Double(i) / 50.0))
            yis.append((Double(i) / 50.0))
        }
        
        for theta in thetavals {
            xcs.append(1+rad*cos(theta))
            ycs.append(1+rad*sin(theta))
            xis.append(1+(rad-TRACKWIDTH/2)*cos(theta))
            yis.append(1+(rad-TRACKWIDTH/2)*sin(theta))
        }
        
        for i in 0..<50 {
            xcs.append(1+rad*cos(thetavals.last!))
            xis.append(1+(rad-(TRACKWIDTH/2))*cos(thetavals.last!))
            ycs.append(1+rad*sin(thetavals.last!) - (Double(i) / 50.0))
            yis.append(1+rad*sin(thetavals.last!) - (Double(i) / 50.0))
        }
        
//        xcs = thetavals.map {(theta: Double) -> Double in return 1+rad*cos(theta)}
//        ycs = thetavals.map {(theta: Double) -> Double in return 1+rad*sin(theta)}
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
        
        if (abs(dxb) < 1e-4 && abs(dxf) < 1e-4) || (abs(dyf) < 1e-4 && abs(dyb) < 1e-4) {
            return 0.1
        }
        
        return termOne-termTwo
    }
    
    // 0 < i < n
    func kmaxConstraintVal(xs: [Double], ys: [Double], i: Int) -> Double {
        let kval = curvatureVal(xs: xs, ys: ys, i: i)
        return -(self.KMAX - kval)
    }
    
    // 0 < i < n
    func frictionConstraintVal(xs: [Double], ys: [Double], i: Int) -> Double {
        let k = curvatureVal(xs: xs, ys: ys, i: i),
            mug = 9.8,
            vsq = k / mug
//        print(k,mug,vsq)
        return abs(k * vsq - mug)
    }
    
    // 0 < i
    func dsConstraintVal(xs: [Double], ys: [Double], i: Int) -> Double {
        // ensure the car isn't warping to different points on the track
        let dx = xs[i] - xs[i-1],
            dy = ys[i] - ys[i-1],
            ds = dx*dx + dy*dy
        return ds
    }
    
    func onTrackConstraintGood(xs: [Double], ys: [Double], i: Int) -> Double {
        let offsetX = xs[i] - self.xcs[i],
            offsetY = ys[i] - self.ycs[i],
            dist = offsetX*offsetX + offsetY*offsetY
        if(dist <= 0.25 * self.TRACKWIDTH*self.TRACKWIDTH) {
            return 0 // should be no contribution
        } else {
            return sqrt(dist)
        }
    }
    
    // no constraint on i
    func onTrackConstraintVal(xs: [Double], ys: [Double], i: Int) -> Double {
        let offsetX = xs[i] - self.xcs[i],
            offsetY = ys[i] - self.ycs[i],
            dist = offsetX*offsetX + offsetY*offsetY
        print("x: \(offsetX), y:\(offsetY)")
        return (0.25 * self.TRACKWIDTH * self.TRACKWIDTH) - dist
    }
    
    // no constraint on i
    func curvatureCenterConstraintVal(xs: [Double], ys: [Double], i: Int) -> Double {
        let offsetX = xs[i] - self.xcs[i],
            offsetY = ys[i] - self.ycs[i],
            curvature = curvatureVal(xs: xs, ys: ys, i: i)
        return abs(offsetX + curvature * offsetY)
    }
    
    func kmaxConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        return kmaxConstraintVal(xs: xs, ys: ys, i: i) <= 0.0
    }
    
    func frictionConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        return frictionConstraintVal(xs: xs, ys: ys, i: i) <= 1.0e-5
    }
    
    func dsConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        return dsConstraintVal(xs: xs, ys: ys, i: i) < 1.0 // arbitrary for now
    }
    
    func onTrackConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        return onTrackConstraintVal(xs: xs, ys: ys, i: i) >= 0.0
        
    }
    
    func curvatureCenterConstraint(xs: [Double], ys: [Double], i: Int) -> Bool {
        return (curvatureCenterConstraintVal(xs: xs, ys: ys, i: i) <= 1.0e-5)
    }
    
    func test(xs: [Double], ys: [Double]) -> Bool {
//        let (xs,ys) = paramtoxy(parameters: parameters)
        for i in 1..<(xs.count-1) {
            if (!kmaxConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!onTrackConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!curvatureCenterConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!frictionConstraint(xs: xs, ys: ys, i: i)) { return false }
            if (!dsConstraint(xs: xs, ys: ys, i: i)) { return false }
        }
        return true
    }
}

