//
//  CostFunction.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/26/22.
//

import Foundation
import LASwift

class timeCostFunction {
//    var N: Int = 150 // this many steps around the circuit
    let finiteDiff = 1.0e-9
    
    func costValue(xs: [Double], ys: [Double], constraint: RacingLineConstraints) -> Double {
        var costVal = 0.0
        for i in 1..<xs.count-1 {
            let k = constraint.curvatureVal(xs: xs, ys: ys, i: i),
                dx = xs[i]-xs[i-1],
                dy = ys[i]-ys[i-1],
                ds = sqrt(dx*dx+dy*dy)
//            print(k,dx,dy,ds)
            costVal += sqrt(abs(k))*ds
        }
        return costVal
    }
    
    func calcPerturbedParam (_ output: inout Double, _ tempxs: [Double], _ tempys: [Double], _ i: Int, _ tempparams: [Double], _ constraint: RacingLineConstraints, _ idx: Int) {
        
        print("i \(i)")
        output = self.costValue(xs: tempxs, ys: tempys, constraint: constraint) * 0.001
        print("Cost: \(output)")
        // have domain restrictions on i
        if i != tempxs.count-1 && i != tempparams.count-1 && i != 0 && i != tempxs.count && i != tempparams.count {
//            print("outer if")
            if ((abs(tempxs[idx] - tempxs[idx-1]) > 1e-4) && (abs(tempxs[idx+1] - tempxs[idx]) > 1e-4)) ||
               ((abs(tempys[idx] - tempys[idx-1]) > 1e-4) && (abs(tempys[idx+1] - tempys[idx]) > 1e-4)) {
//                print("inner if")
                // kmax
//                let kmaxv = constraint.kmaxConstraintVal(xs: tempxs, ys: tempys, i: idx) / constraint.KMAX
//                if !kmaxv.isNaN {
//                    output += 0.00001 * kmaxv
//                    print("kmax \(kmaxv)")
//                } else { print("KMAX NAN") }

                // friction
                let fricv = constraint.frictionConstraintVal(xs: tempxs, ys: tempys, i: idx) / 9.81
                if !fricv.isNaN {
                    output += 0.001 * fricv
                    print("fricv \(fricv)")
                } else { print("fricv NAN") }

                // curvcenter
                let ccv = constraint.curvatureCenterConstraintVal(xs: tempxs, ys: tempys, i: idx)
                if !ccv.isNaN {
                    output += 0.01 * ccv
                    print("ccv \(ccv)")
                } else { print("ccv NAN") }
                
                // ds
                let dsv = constraint.dsConstraintVal(xs: tempxs, ys: tempys, i: idx)
                if !dsv.isNaN {
                    output += 0.1 * dsv
                    print("dsv \(dsv)")
                } else { print("dsv NAN") }
            }

        }

        // do not have domain restrictions
        let ontrackVal = constraint.onTrackConstraintGood(xs: tempxs, ys: tempys, i: idx)
        if !ontrackVal.isNaN {
            output += 0.01 * ontrackVal
//            print("otv: \(ontrackVal)")
        } else {
            print("ontrackVal NAN")
        }
    }
    
    func gradient(gradx: inout [Double], grady: inout [Double], xs: [Double], ys: [Double], constraint: RacingLineConstraints) {
        let batchnums = 3 // perturb this number at a time
        var fp : Double, fm : Double
        var tempparams = xs, tempxs = xs, tempys = ys
        tempparams.append(contentsOf: ys)
        let copy = tempparams
        print("\n\n***New Gradient***\n\n")
//        for i in 0..<tempparams.count {
        for i in 0..<tempparams.count-batchnums {
            let idx: Int
            if 0 <= i && i < xs.count { idx = i } else { idx = i-xs.count }
            for j in 0..<batchnums {
                // boundary terms do not work, on boundary or perturbing xs and ys
                if (tempxs.count - batchnums < idx + j && idx + j < tempxs.count) {
                    print(j)
                    tempparams[i+j] += finiteDiff
                    if 0 <= idx+j && idx+j < xs.count { tempxs[idx+j] += finiteDiff /* perturb only x */ }
                    else { tempys[idx+j] += finiteDiff }
                }
            }
//            tempparams[i] += finiteDiff
//            if 0 <= idx && idx < xs.count { tempxs[idx] += finiteDiff /* perturb only x */ }
//            else { tempys[idx] += finiteDiff }
            fp = 0.0
            calcPerturbedParam(&fp, tempxs, tempys, i, tempparams, constraint, idx)
            
            for j in 0..<batchnums {
                if (tempxs.count - batchnums < idx + j && idx + j < tempxs.count) {
                    tempparams[i+j] -= 2.0*finiteDiff
                    if 0 <= idx && idx < xs.count { tempxs[idx+j] -= 2.0*finiteDiff }
                    else { tempys[idx+j] -= 2.0*finiteDiff }
                }
            }
//            tempparams[i] -= 2.0*finiteDiff
//            if 0 <= idx && idx < xs.count { tempxs[idx] -= 2.0*finiteDiff }
//            else { tempys[idx] -= 2.0*finiteDiff }
            fm = 0.0
            calcPerturbedParam(&fm, tempxs, tempys, i, tempparams, constraint, idx)
            
            let gradval = 0.5 * (fp - fm) / finiteDiff
            
            if 0 <= i && i < xs.count {
                gradx[idx] = gradval
            } else {
                grady[idx] = gradval
            }
//            grad[i] = 0.5 * (fp - fm) / finiteDiff
            tempparams[i] = copy[i]
            tempxs = xs
            tempys = ys
        }
        
    }
    
    func valueAndGradient(gradx: inout [Double], grady: inout [Double], xs: [Double], ys: [Double], constraint: RacingLineConstraints) -> Double {
        self.gradient(gradx: &gradx, grady: &grady, xs: xs, ys: ys, constraint: constraint)
        return costValue(xs: xs, ys: ys, constraint: constraint)
    }
    
}
