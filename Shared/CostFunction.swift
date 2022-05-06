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
    let finiteDiff = 2.0
    
    func costValue(xs: [Double], ys: [Double], constraint: RacingLineConstraints) -> Double {
        var costVal = 0.0
        for i in 1..<xs.count-2 {
            let k = constraint.curvatureVal(xs: xs, ys: ys, i: i),
                dxb = xs[i]-xs[i-1],
                dyb = ys[i]-ys[i-1],
                dsb = sqrt(dxb*dxb+dyb*dyb),
                dxf = xs[i+1]-xs[i],
                dyf = ys[i+1]-ys[i],
                dsf = sqrt(dxf*dxf+dyf*dyf),
                ds = 0.5 * (dsf + dsb)
//            print("in cost \(i): \(k),\(dx),\(dy),\(ds)")
//            print("Adding: \(sqrt(abs(k))*ds)")
            costVal += sqrt(abs(k))*ds
        }
        return costVal
    }
    
    func calcPerturbedParam (_ output: inout Double, _ tempxs: [Double], _ tempys: [Double], _ i: Int, _ tempparams: [Double], _ constraint: RacingLineConstraints, _ idx: Int, costWt: Double, kmaxWt: Double, fricWt: Double, ccvWt: Double, dsWt: Double, onTrackWt: Double) {
//        print("i \(i)")
        let costVal = self.costValue(xs: tempxs, ys: tempys, constraint: constraint)
        if !costVal.isNaN {
            output += costWt * costVal
        } else { print("cost NAN") }
        print("Cost: \(output)")
        let debug = true
        // have domain restrictions on i
        if i != tempxs.count-1 && i != tempparams.count-1 && i != 0 && i != tempxs.count && i != tempparams.count {
//            print("outer if")
            if ((abs(tempxs[idx] - tempxs[idx-1]) > 1e-4) && (abs(tempxs[idx+1] - tempxs[idx]) > 1e-4)) ||
               ((abs(tempys[idx] - tempys[idx-1]) > 1e-4) && (abs(tempys[idx+1] - tempys[idx]) > 1e-4)) {
//                print("inner if")
                // kmax
                let kmaxv = constraint.kmaxConstraintVal(xs: tempxs, ys: tempys, i: idx) / constraint.KMAX
                if !kmaxv.isNaN {
                    output += kmaxWt * kmaxv
                } else { print("KMAX NAN") }

                // friction
                let fricv = constraint.frictionConstraintVal(xs: tempxs, ys: tempys, i: idx) / 9.81
                if !fricv.isNaN {
                    output += fricWt * fricv
                } else { print("fricv NAN") }

                // curvcenter
                let ccv = constraint.curvatureCenterConstraintVal(xs: tempxs, ys: tempys, i: idx)
                if !ccv.isNaN {
                    output += ccvWt * ccv
                } else { print("ccv NAN") }

                // ds
                let dsv = constraint.dsConstraintVal(xs: tempxs, ys: tempys, i: idx)
                if !dsv.isNaN {
                    output += dsWt * dsv
//                    print("dsv \(dsv)")
                } else { print("dsv NAN") }
                if(debug) {
                    print("\(i): kmax \(kmaxv)")
                    print("fricv \(fricv)")
                    print("ccv \(ccv)")
                    print("dsv \(dsv)")
                }
            }
            print("Final val: \(output)")
        }

        // do not have domain restrictions
        let ontrackVal = constraint.onTrackConstraintGood(xs: tempxs, ys: tempys, i: idx)
        if !ontrackVal.isNaN {
            output += onTrackWt * ontrackVal
            print("otv: \(ontrackVal)")
        } else {
            print("ontrackVal NAN")
        }
    }
    
    func gradient(gradx: inout [Double], grady: inout [Double], xs: [Double], ys: [Double], constraint: RacingLineConstraints, costWt: Double, kmaxWt: Double, fricWt: Double, ccvWt: Double, dsWt: Double, onTrackWt: Double) {
        let batchnums = 5 // perturb this number at a time
        var fp : Double, fm : Double
        var tempparams = xs, tempxs = xs, tempys = ys
        tempparams.append(contentsOf: ys)
        let copy = tempparams
//        print("\n\n***New Gradient***\n\n")
//        for i in 0..<tempparams.count {
        for i in 0..<tempparams.count-batchnums+1 {
            let idx: Int
            if 0 <= i && i < xs.count { idx = i } else { idx = i-xs.count }
            for j in 0..<batchnums {
                // boundary terms do not work, on boundary or perturbing xs and ys
                if (tempxs.count - batchnums < idx + j && idx + j < tempxs.count) {
//                    print(j)
                    tempparams[i+j] += finiteDiff
                    if 0 <= idx+j && idx+j < xs.count { tempxs[idx+j] += finiteDiff /* perturb only x */ }
                    else { tempys[idx+j] += finiteDiff }
                }
            }
//            tempparams[i] += finiteDiff
//            if 0 <= idx && idx < xs.count { tempxs[idx] += finiteDiff /* perturb only x */ }
//            else { tempys[idx] += finiteDiff }
            fp = 0.0
            calcPerturbedParam(&fp, tempxs, tempys, i, tempparams, constraint, idx, costWt: costWt, kmaxWt: kmaxWt, fricWt: fricWt, ccvWt: ccvWt, dsWt: dsWt, onTrackWt: onTrackWt)
//            calcPerturbedParam(&fp, tempxs, tempys, i, tempparams, constraint, idx, costWt: costWt, fricWt: costWt)
            
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
            calcPerturbedParam(&fm, tempxs, tempys, i, tempparams, constraint, idx, costWt: costWt, kmaxWt: kmaxWt, fricWt: fricWt, ccvWt: ccvWt, dsWt: dsWt, onTrackWt: onTrackWt)
            
//            print(fp,fm)
            let gradval = 0.5 * (fp + fm) / finiteDiff
//            print(gradval)
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
}
