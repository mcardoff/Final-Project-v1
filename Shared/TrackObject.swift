//
//  TrackObject.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/8/22.
//

import Foundation
import AppKit

// can
class Track {
    var name : String = ""
    var KMAX : Double, TRACKWIDTH : Double
    var xcs : [Double], ycs : [Double]
    let GRAVITY = 9.8, FRICTION = 1.0
//    var curvatureVals
    
    init() {
        // do basic one as an example
        KMAX = 0.5
        TRACKWIDTH = 1.50
        var thetavals : [Double] = [], n = 150
        for i in 0..<n { thetavals.append(Double(i) * Double.pi / (2.0 * Double(n))) }
        
        let rad = 1.1
        xcs = thetavals.map {(theta: Double) -> Double in return rad*cos(theta)}
        ycs = thetavals.map {(theta: Double) -> Double in return rad*sin(theta)}
        
        name = "Test"
    }
    
    init(kMax: Double, trackWidth: Double, centerLineX: [Double], centerLineY: [Double], nameStr: String) {
        // do basic one as an example
        KMAX = kMax
        TRACKWIDTH = trackWidth
        xcs = centerLineX
        ycs = centerLineY
        name = nameStr
    }
    
    func calculateDeltaNorm(i: Int, xs: [Double], ys: [Double], dt: Double) -> (Double, Double) {
        assert(i >= 0 && i < xs.count - 2)
        let dx = xs[i+1]-xs[i],
            dy = ys[i+1]-ys[i],
            dxdt = dx/dt,
            dydt = dy/dt,
            mag = sqrt(dxdt*dxdt+dydt*dydt)
        return (dxdt / mag, dydt / mag)
    }
    
}
