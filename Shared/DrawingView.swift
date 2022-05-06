//
//  DrawingView.swift
//  Monte Carlo Integration
//
//  Created by Jeff Terry on 12/31/20.
//

import SwiftUI

let SCALE = 2.9

struct drawingView: View {
    
    @Binding var xs : [Double]
    @Binding var ys : [Double]
    @Binding var optObj : OptimizationOfPath
    
    var body: some View {
        
        
        ZStack{
            drawExampleAxes()
                .stroke(Color.black)
            drawPoints(xs: optObj.track.xcs, ys: optObj.track.ycs)
                .stroke(Color.blue)
            drawPoints(xs: optObj.track.xis, ys: optObj.track.yis)
                .stroke(Color.red)
            drawPoints(xs: optObj.track.xos, ys: optObj.track.yos)
                .stroke(Color.red)
            drawPath(xs: xs, ys: ys)
                .stroke(Color.green)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fill)
        
    }
}

struct drawExampleAxes: Shape {
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: 0.025*rect.width, y: rect.height * (1-0.025)),
            scale = rect.width/SCALE
        
        // Create the Path for the display
        var path = Path()
        for x in stride(from: 0.0, through: 1.0, by: 0.1) {
            let newx = x*Double(scale)+Double(center.x),
                newy = -0.0*Double(scale)+Double(center.y)
            path.addRect(CGRect(
                x: newx,
                y: newy,
                width: 1.0 , height: 1.0))
        }
        
        for y in stride(from: 0.0, through: 1.0, by: 0.1) {
            let newx = 0.0*Double(scale)+Double(center.x),
                newy = -y*Double(scale)+Double(center.y)
            path.addRect(CGRect(
                x: newx,
                y: newy,
                width: 1.0 , height: 1.0))
        }
        
        return (path)
    }
}

struct drawPath: Shape {
    var xs: [Double], ys: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        if(xs.isEmpty || ys.isEmpty) { return path }
        
        let center = CGPoint(x: 0.025*rect.width, y: rect.height * (1-0.025)),
            scale = rect.width/SCALE,
            newx0 = xs[0]*Double(scale)+Double(center.x),
            newy0 = -ys[0]*Double(scale)+Double(center.y)
        
        path.move(to: CGPoint(x: newx0, y: newy0))
        
        for i in 1..<xs.count {
            let newx = xs[i]*Double(scale)+Double(center.x),
                newy = -ys[i]*Double(scale)+Double(center.y)
            path.addLine(to: CGPoint(x: newx, y: newy))
        }
        
        return path
    }
    
}

struct drawPoints: Shape {
    var xs : [Double], ys: [Double]
    
    func path(in rect: CGRect) -> Path {
        // draw from the center of our rectangle
        let center = CGPoint(x: 0.025*rect.width, y: rect.height * (1-0.025)),
            scale = rect.width/SCALE
        
        // Create the Path for the display
        var path = Path()
        for (x,y) in zip(xs,ys) {
            let newx = x*Double(scale)+Double(center.x),
                newy = -y*Double(scale)+Double(center.y)
            path.addRect(CGRect(
                x: newx,
                y: newy,
                width: 1.0 , height: 1.0))
        }
        return (path)
    }
}
