//
//  TrackObject.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/8/22.
//

import Foundation
import AppKit

enum TrackType: CaseIterable, Identifiable {
    static var allCases : [TrackType] {
        return [.leftHander, .uTurn, .oval]
    }
    case leftHander, uTurn, oval
    
    var id: Self { self }
    
    func toString() -> String {
        switch self {
        case .leftHander:
            return "Left Hander"
        case .uTurn:
            return "U-Turn"
        case .oval:
            return "Oval"
        }
    }
}


class Track {
    var name : String = ""
    var KMAX : Double = 0.0, TRACKWIDTH : Double = 0.0
    var xcs : [Double], ycs : [Double]
    var xis : [Double], yis : [Double]
    var xos : [Double], yos : [Double]
    let GRAVITY = 9.8, FRICTION = 1.0
    
    init() {
        xcs = []; ycs = []
        xis = []; yis = []
        xos = []; yos = []
    }
    
//    init(xcs : [Double], ycs : [Double],  xis : [Double], yis : [Double], xos : [Double], yos : [Double], KMAX : Double, TRACKWIDTH : Double) {
//        self.TRACKWIDTH = TRACKWIDTH
//        self.KMAX = KMAX
//        self.xcs = xcs; self.ycs = ycs
//        self.xcs = xos; self.ycs = yos
//        self.xcs = xis; self.ycs = yis
//    }
    
    init(track: TrackType, KMAX : Double, TRACKWIDTH : Double) {
        self.TRACKWIDTH = TRACKWIDTH
        self.KMAX = KMAX
        xcs = []; ycs = []
        xis = []; yis = []
        xos = []; yos = []
        switch track {
        case .leftHander:
            var thetavals : [Double] = [], n = 150
            for i in 0..<n { thetavals.append(Double(i) * 2.0 * Double.pi / (4.0 * Double(n))) }
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
                xis.append(1+(rad-TRACKWIDTH/2)*cos(theta))
                xos.append(1+(rad+TRACKWIDTH/2)*cos(theta))
                ycs.append(1+rad*sin(theta))
                yis.append(1+(rad-TRACKWIDTH/2)*sin(theta))
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
        case .uTurn:
            var thetavals : [Double] = [], n = 150
            for i in 0..<n {
                thetavals.append(Double(i) * 2.0 * Double.pi / (2.0 * Double(n)))
            }
            
            let rad = 1.0
            for i in 0..<50 {
                xcs.append(1+rad)
                ycs.append((Double(i) / 50.0))
                xis.append(1+rad-TRACKWIDTH/2)
                yis.append((Double(i) / 50.0))
                xos.append(1+rad+TRACKWIDTH/2)
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
            
            for i in 0...50 {
                // x same, y changes
                xcs.append(1+rad*cos(thetavals.last!))
                ycs.append(1+rad*sin(thetavals.last!) - (Double(i) / 50.0))
                xis.append(1+(rad-TRACKWIDTH/2)*cos(thetavals.last!))
                yis.append(1+(rad-(TRACKWIDTH/2))*sin(thetavals.last!) - (Double(i) / 50.0))
                xos.append(1+(rad+(TRACKWIDTH/2))*cos(thetavals.last!))
                yos.append(1+(rad+(TRACKWIDTH/2))*sin(thetavals.last!) - (Double(i) / 50.0))
                
            }
        case .oval:
            // tbd
            return
        }
    }
}
class LeftHander : Track {
    override init() {
        super.init()
        // do basic left hander as an example
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

class UTurnTrack: Track {
    override init() {
        super.init()
        // UTurn
        KMAX = 0.5
        TRACKWIDTH = 1.50
        var thetavals : [Double] = [], n = 150
        for i in 0..<n {
            thetavals.append(Double(i) * 2.0 * Double.pi / (2.0 * Double(n)))
        }
        
        xcs = []; ycs = []
        xis = []; yis = []
        xos = []; yos = []
        let rad = 1.0
        for i in 0..<50 {
            xcs.append(1+rad)
            ycs.append((Double(i) / 50.0))
            xis.append(1+rad-TRACKWIDTH/2)
            yis.append((Double(i) / 50.0))
            xos.append(1+rad+TRACKWIDTH/2)
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
        
        for i in 0...50 {
            // x same, y changes
            xcs.append(1+rad*cos(thetavals.last!))
            ycs.append(1+rad*sin(thetavals.last!) - (Double(i) / 50.0))
            xis.append(1+rad*cos(thetavals.last!))
            yis.append(1+(rad-(TRACKWIDTH/2))*sin(thetavals.last!) - (Double(i) / 50.0))
            xos.append(1+rad*cos(thetavals.last!))
            yos.append(1+(rad+(TRACKWIDTH/2))*sin(thetavals.last!) - (Double(i) / 50.0))
            
        }
        
//        print(xcs)
        
//        xcs = thetavals.map {(theta: Double) -> Double in return 1+rad*cos(theta)}
//        ycs = thetavals.map {(theta: Double) -> Double in return 1+rad*sin(theta)}
        
        name = "U Turn"
    }
}
