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
        return [.leftHander, .hairpin, .oval]
    }
    case leftHander, hairpin, oval
    
    var id: Self { self }
    
    func toString() -> String {
        switch self {
        case .leftHander:
            return "Left Hander"
        case .hairpin:
            return "Hairpin"
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
            
            for i in 0...50 {
                xcs.append(1+rad*cos(thetavals.last!) - (Double(i) / 50.0))
                xis.append(1+rad*cos(thetavals.last!) - (Double(i) / 50.0))
                xos.append(1+rad*cos(thetavals.last!) - (Double(i) / 50.0))
                ycs.append(1+rad*sin(thetavals.last!))
                yis.append(1+(rad-(TRACKWIDTH/2))*sin(thetavals.last!))
                yos.append(1+(rad+(TRACKWIDTH/2))*sin(thetavals.last!))
                
            }
        case .hairpin:
            var thetavals : [Double] = [], n = 150
            for i in 0..<n {
                thetavals.append(Double(i) * 2.0 * Double.pi / (2.0 * Double(n)))
            }
            
            let rad = 0.8, xshift = 1.4, yshift = 1.0
            for i in 0..<50 {
                xcs.append(xshift+rad)
                ycs.append((Double(i) / 50.0))
                xis.append(xshift+rad-TRACKWIDTH/2)
                yis.append((Double(i) / 50.0))
                xos.append(xshift+rad+TRACKWIDTH/2)
                yos.append((Double(i) / 50.0))
            }
            
            for theta in thetavals {
                xcs.append(xshift+rad*cos(theta))
                ycs.append(yshift+rad*sin(theta))
                xis.append(xshift+(rad-TRACKWIDTH/2)*cos(theta))
                yis.append(yshift+(rad-TRACKWIDTH/2)*sin(theta))
                xos.append(xshift+(rad+TRACKWIDTH/2)*cos(theta))
                yos.append(yshift+(rad+TRACKWIDTH/2)*sin(theta))
            }
            
            for i in 0...50 {
                // x same, y changes
                xcs.append(xshift+rad*cos(thetavals.last!))
                ycs.append(yshift+rad*sin(thetavals.last!) - (Double(i) / 50.0))
                xis.append(xshift+(rad-TRACKWIDTH/2)*cos(thetavals.last!))
                yis.append(yshift+(rad-(TRACKWIDTH/2))*sin(thetavals.last!) - (Double(i) / 50.0))
                xos.append(xshift+(rad+(TRACKWIDTH/2))*cos(thetavals.last!))
                yos.append(yshift+(rad+(TRACKWIDTH/2))*sin(thetavals.last!) - (Double(i) / 50.0))
            }
        case .oval:
//            var thetavals : [Double] = [],
            var n = 150
//            for i in 0..<n {
//                thetavals.append(Double(i) * 2.0 * Double.pi / (2.0 * Double(n)))
//            }
            
            let rad = 0.8, xshift = 2.8, yshift = 2.0, n1 = 50, scaleval = 2.5
            for i in 0..<n1 {
                xcs.append(xshift+rad)
                ycs.append((scaleval*Double(i) / Double(n1))+yshift/2)
                xis.append(xshift+rad-TRACKWIDTH/2)
                yis.append((scaleval*Double(i) / Double(n1))+yshift/2)
                xos.append(xshift+rad+TRACKWIDTH/2)
                yos.append((scaleval*Double(i) / Double(n1))+yshift/2)
            }
            
            for i in 0..<n {
                let theta = Double(i) * (Double.pi / 2.0) / Double(n)// between 0 and pi/2
                xcs.append(xshift+(rad)*cos(theta))
                ycs.append(scaleval-1+yshift+(rad)*sin(theta))
                xis.append(xshift+(rad-TRACKWIDTH/2)*cos(theta))
                yis.append(scaleval-1+yshift+(rad-TRACKWIDTH/2)*sin(theta))
                xos.append(xshift+(rad+TRACKWIDTH/2)*cos(theta))
                yos.append(scaleval-1+yshift+(rad+TRACKWIDTH/2)*sin(theta))
            }
            
            var lastxc = xcs.last!, lastyc = ycs.last!,
                lastxi = xis.last!, lastyi = yis.last!,
                lastxo = xos.last!, lastyo = yos.last!
            for i in 0..<n1 {
                // same y, diff x
                xcs.append(lastxc-(Double(i) / Double(n1)))
                ycs.append(lastyc)
                xis.append(lastxi-(Double(i) / Double(n1)))
                yis.append(lastyi)
                xos.append(lastxo-(Double(i) / Double(n1)))
                yos.append(lastyo)
            }
            
            for i in 0..<n {
                let theta = Double.pi / 2.0 + Double(i) * (Double.pi / 2.0) / Double(n)// between 0 and pi/2
                xcs.append(xshift+(rad)*cos(theta)-1)
                ycs.append(yshift+(rad)*sin(theta)+scaleval-1)
                xis.append(xshift+(rad-TRACKWIDTH/2)*cos(theta)-1)
                yis.append(yshift+(rad-TRACKWIDTH/2)*sin(theta)+scaleval-1)
                xos.append(xshift+(rad+TRACKWIDTH/2)*cos(theta)-1)
                yos.append(yshift+(rad+TRACKWIDTH/2)*sin(theta)+scaleval-1)
            }
            
            lastxc = xcs.last!; lastyc = ycs.last!
            lastxi = xis.last!; lastyi = yis.last!
            lastxo = xos.last!; lastyo = yos.last!
            for i in 0..<n1 {
                // same x, diff y
                xcs.append(lastxc)
                ycs.append(lastyc-(scaleval*Double(i) / Double(n1)))
                xis.append(lastxi)
                yis.append(lastyi-(scaleval*Double(i) / Double(n1)))
                xos.append(lastxo)
                yos.append(lastyo-(scaleval*Double(i) / Double(n1)))
            }
            
            for i in 0..<n {
                let theta = Double.pi + Double(i) * (Double.pi / 2.0) / Double(n)// between 0 and pi/2
                xcs.append(xshift+(rad)*cos(theta)-1)
                ycs.append(yshift+(rad)*sin(theta)-1)
                xis.append(xshift+(rad-TRACKWIDTH/2)*cos(theta)-1)
                yis.append(yshift+(rad-TRACKWIDTH/2)*sin(theta)-1)
                xos.append(xshift+(rad+TRACKWIDTH/2)*cos(theta)-1)
                yos.append(yshift+(rad+TRACKWIDTH/2)*sin(theta)-1)
            }
            
            lastxc = xcs.last!; lastyc = ycs.last!
            lastxi = xis.last!; lastyi = yis.last!
            lastxo = xos.last!; lastyo = yos.last!
            for i in 0..<n1 {
                // same y, diff x
                xcs.append(lastxc+(Double(i) / Double(n1)))
                ycs.append(lastyc)
                xis.append(lastxi+(Double(i) / Double(n1)))
                yis.append(lastyi)
                xos.append(lastxo+(Double(i) / Double(n1)))
                yos.append(lastyo)
            }
            
            for i in 0..<n {
                let theta = 3*Double.pi/2 + Double(i) * (Double.pi / 2.0) / Double(n)// between 0 and pi/2
                xcs.append(xshift+(rad)*cos(theta))
                ycs.append(yshift+(rad)*sin(theta)-1)
                xis.append(xshift+(rad-TRACKWIDTH/2)*cos(theta))
                yis.append(yshift+(rad-TRACKWIDTH/2)*sin(theta)-1)
                xos.append(xshift+(rad+TRACKWIDTH/2)*cos(theta))
                yos.append(yshift+(rad+TRACKWIDTH/2)*sin(theta)-1)
            }
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
