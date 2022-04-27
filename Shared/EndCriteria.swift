//
//  EndCriteria.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 4/27/22.
//

import Foundation

enum EndCriteriaType {
    case None,
    MaxIterations,
    StationaryPoint,
    StationaryFunctionValue,
    StationaryFunctionAccuracy,
    ZeroGradientNorm,
    Unknown
}

class EndCriteria {
    
    var maxIterations : Int
    var maxStationaryStateIterations : Int
    var rootEpsilon : Double
    var functionEpsilon : Double
    var gradientNormEpsilon : Double
    
    init(maxIterations : Int, maxStationaryStateIterations : Int,
        rootEpsilon : Double, functionEpsilon : Double,
        gradientNormEpsilon : Double) {
        self.maxIterations = maxIterations
        self.maxStationaryStateIterations = maxStationaryStateIterations
        self.rootEpsilon = rootEpsilon
        self.functionEpsilon = functionEpsilon
        self.gradientNormEpsilon = gradientNormEpsilon
            
        //@ missing treatment
    }
    
    func checkMaxIterations(iteration: Int, endCriteriaType : inout EndCriteriaType) -> Bool {
        if iteration < maxIterations {
            return false
        }
        
        endCriteriaType = EndCriteriaType.MaxIterations
        return true
    }
    
    func checkStationaryPoint(xOld : Double, xNew : Double, stationaryStateIterations : inout Int, endCriteriaType : inout EndCriteriaType) -> Bool {
        if abs(xNew - xOld) >= rootEpsilon {
            stationaryStateIterations = 0
            return false
        }
        stationaryStateIterations += 1
        if (stationaryStateIterations <= maxStationaryStateIterations) {
            return false
        }
        endCriteriaType = EndCriteriaType.StationaryPoint
        return false
    }
    
    
    func checkStationaryFunctionValue(fxOld : Double, fxNew : Double, stationaryStateIterations : inout Int, endCriteriaType : inout EndCriteriaType) -> Bool {
        
        if abs(fxNew-fxOld) >= functionEpsilon {
            stationaryStateIterations = 0
            return false
        }
        stationaryStateIterations += 1
        if stationaryStateIterations <= maxStationaryStateIterations {
            return false
        }

        endCriteriaType = EndCriteriaType.StationaryFunctionValue
        return false
    }

    
    func checkStationaryFunctionAccuracy(f : Double, positiveOptimization : Bool, endCriteriaType : inout EndCriteriaType) -> Bool {
        if (!positiveOptimization) {
            return false
        }
        if (f >= functionEpsilon) {
            return false
        }
        endCriteriaType = EndCriteriaType.StationaryFunctionAccuracy
        return true;
    }
    
    func checkZeroGradientNorm(gradientNorm : Double, endCriteriaType : inout EndCriteriaType) -> Bool {
        if (gradientNorm >= gradientNormEpsilon) {
            return false
        }
        endCriteriaType = EndCriteriaType.ZeroGradientNorm
        return true;
    }
    
    func check(iteration : Int, stationaryStateIterations : inout Int, positiveOptimization : Bool, fold : Double, normgold : Double, fnew : Double, normgnew : Double, endCriteriaType : inout EndCriteriaType) -> Bool {
        
        return (checkMaxIterations(iteration: iteration, endCriteriaType: &endCriteriaType) ||
                checkStationaryFunctionValue(fxOld: fold, fxNew: fnew, stationaryStateIterations: &stationaryStateIterations, endCriteriaType: &endCriteriaType) ||
                checkStationaryFunctionAccuracy(f: fnew, positiveOptimization: positiveOptimization, endCriteriaType: &endCriteriaType) ||
                checkZeroGradientNorm(gradientNorm: normgnew, endCriteriaType: &endCriteriaType))
    }

    
}
