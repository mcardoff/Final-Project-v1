//
//  DrawingView.swift
//  Monte Carlo Integration
//
//  Created by Jeff Terry on 12/31/20.
//

import SwiftUI

struct drawingView: View {
    
    @Binding var optObj : OptimizationOfPath
    
    var body: some View {
        
        
        ZStack{
            drawPath(xs: optObj.xits, ys: optObj.yits)
                .stroke(Color.black)
            drawPath(xs: optObj.xots, ys: optObj.yots)
                .stroke(Color.black)
            drawPath(xs: optObj.xcs, ys: optObj.ycs)
                .stroke(Color.blue)
            drawPath(xs: optObj.xs, ys: optObj.ys)
                .stroke(Color.red)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fill)
        
    }
}

struct drawPath: Shape {
    var xs : [Double], ys: [Double]
    
    func path(in rect: CGRect) -> Path {
        // draw from the center of our rectangle
        let center = CGPoint(x: 0, y: rect.height),
            scale = rect.width/2
        
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
