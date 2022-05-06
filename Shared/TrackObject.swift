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
    var xis : [Double], yis : [Double]
    var xos : [Double], yos : [Double]
    let GRAVITY = 9.8, FRICTION = 1.0
//    var curvatureVals
    
    init() {
        // do basic one as an example
        KMAX = 0.5
        TRACKWIDTH = 1.50
        var thetavals : [Double] = [], n = 150
        for i in 0..<n {
            thetavals.append(Double(i) * 2.0 * Double.pi / (4.0 * Double(n)))
        }
        
        xcs = []; ycs = []
        xis = []; yis = []
        xos = []; yos = []
        let rad = 1.0
        for i in 0..<50 {
            xcs.append(1+rad)
            xis.append(1+rad-TRACKWIDTH/2)
            xos.append(1+rad+TRACKWIDTH/2)
            ycs.append((Double(i) / 50.0))
            yis.append((Double(i) / 50.0))
            yos.append((Double(i) / 50.0))
        }
        
        for theta in thetavals {
            xcs.append(1+rad*cos(theta))
            ycs.append(1+rad*sin(theta))
            xis.append(1+(rad-TRACKWIDTH/2)*cos(theta))
            yis.append(1+(rad-TRACKWIDTH/2)*sin(theta))
            xos.append(1+(rad+TRACKWIDTH/2)*cos(theta))
            yos.append(1+(rad+TRACKWIDTH/2)*sin(theta))
        }
        
        for i in 1...50 {
            xcs.append(1+rad*cos(thetavals.last!) - (Double(i) / 50.0))
            xis.append(1+rad*cos(thetavals.last!) - (Double(i) / 50.0))
            xos.append(1+rad*cos(thetavals.last!) - (Double(i) / 50.0))
            ycs.append(1+rad*sin(thetavals.last!))
            yis.append(1+(rad-(TRACKWIDTH/2))*sin(thetavals.last!))
            yos.append(1+(rad+(TRACKWIDTH/2))*sin(thetavals.last!))
            
        }
        
//        xcs = thetavals.map {(theta: Double) -> Double in return 1+rad*cos(theta)}
//        ycs = thetavals.map {(theta: Double) -> Double in return 1+rad*sin(theta)}
        
        name = "Test"
    }
    
    init(kMax: Double, trackWidth: Double, centerLineX: [Double], centerLineY: [Double], nameStr: String) {
        // do basic one as an example
        KMAX = kMax
        TRACKWIDTH = trackWidth
        xcs = centerLineX
        ycs = centerLineY
        name = nameStr
        yis = []
        xis = []
        yos = []
        xos = []
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
