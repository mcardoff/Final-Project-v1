//
//  LineSearch.swift
//  Final Project V1
//
//  Created by Michael Cardiff on 5/3/22.
//

import Foundation
import LASwift

class LineSearch {
    var searchDirection : Matrix
    var xtd : Matrix
    var gradient : Matrix
    var qt = 0.0
    var qpt = 0.0
    var succeed = true
    
    init() {
        searchDirection = Matrix(Array(repeating: 0.0, count: 0))
        xtd = Matrix(Array(repeating: 0.0, count: 0))
        gradient = Matrix(Array(repeating: 0.0, count: 0))
    }
    
    func lastX() -> Matrix {
        return xtd
    }
    
    func lastFunctionValue() -> Double {
        return qt
    }
    
    func lastGradient() -> Matrix {
        return gradient
    }
    
    func lastGradientNorm2() -> Double {
        return qpt
    }
    
    func search( problem : inout Problem, endCriteriaType : inout EndCriteriaType, endCriteria : EndCriteria, initialValue : Double) -> Double { return 0.0 }
    
    func update( parameters : inout Matrix, direction : Matrix, beta : Double, constraint : Constraint) -> Double {
        var diff = beta
        var newParams = Matrix(parameters.rows,parameters.cols)
        for i in 0..<parameters.flat.count {
            newParams[i] = parameters[i] + diff * direction[i]
        }
        //parameters + diff * direction
        var valid = constraint.test(parameters: newParams)
        var icount = 0
        while !valid {
            assert (icount <= 200, "Can't update linesearch!")
            diff *= 0.5
            icount += 1
            for i in 0..<newParams.flat.count {
                newParams[i] = parameters[i] + diff * direction[i]
            }
            
            valid = constraint.test(parameters: newParams)
        }
        for i in 0..<parameters.flat.count {
            newParams[i] = parameters[i] + diff * direction[i]
        }
        //parameters = parameters + diff * direction
        return diff
    }
    
    
    
}

class ArmijoLineSearch : LineSearch {
    
    var alpha : Double
    var beta : Double

    init(eps : Double = 1e-8, alpha : Double = 0.05, beta : Double = 0.65) {
        self.alpha = alpha
        self.beta = beta
        
        super.init()
    }
    
    override func search( problem: inout Problem, endCriteriaType: inout EndCriteriaType, endCriteria: EndCriteria, initialValue: Double) -> Double {
        var constraint = problem.constraint
        succeed = true
        
        var maxIter = false
        var qtold : Double
        var t = initialValue
        var loopNumber = 0
        
        var q0 : Double = problem.functionValue
        var qp0 : Double = problem.squaredNorm
        
        qt = q0
        
        if gradient.flat.count == 0 {
            qpt = qp0
        } else {
            qpt = (dotinside(lhs:gradient, rhs: searchDirection)) * -1.0
        }
        
        
        gradient = Matrix(Array(repeating: 0.0, count : problem.currentValue.flat.count))
        xtd = problem.currentValue
        t = update(parameters: &xtd, direction: searchDirection, beta: t, constraint: constraint)
        qt = problem.value(parameters: xtd)
        
        if qt - q0 > (-alpha * t * qpt) {
            
            repeat {
                loopNumber += 1
                t *= beta
                qtold = qt
                xtd = problem.currentValue
                t = update(parameters: &xtd, direction: searchDirection, beta: t, constraint: constraint)
                
                qt = problem.value(parameters: xtd)
                problem.gradient(grad: &gradient, parameters: xtd)
                maxIter = endCriteria.checkMaxIterations(iteration: loopNumber, endCriteriaType: &endCriteriaType)
                
            } while ((((qt - q0) > (-alpha * t * qpt)) || ((qtold - q0) <= (-alpha * t * qpt / beta))) &&
                (!maxIter))
            
        }
        
        if maxIter {
            succeed = false
        }
        
        problem.gradient(grad: &gradient, parameters: xtd)
        qpt = dotinside(lhs: gradient, rhs: gradient)
        return t
        
    }
    
    
}


class LineSearchBasedMethod : OptimizationMethod {
    var lineSearch : LineSearch
    
    init(lineSearch : LineSearch = ArmijoLineSearch()) {
        self.lineSearch = lineSearch
    }
    
    func minimize( problem: inout Problem, endCriteria: EndCriteria) -> EndCriteriaType {
        // Initializations
        var ftol = endCriteria.functionEpsilon
        var maxStationaryStateIterations_ = endCriteria.maxStationaryStateIterations
        var ecType = EndCriteriaType.None
        problem.reset()                                      // reset problem
        
        var x_ = problem.currentValue              // store the starting point
        var iterationNumber_ = 0
        
        // dimension line search
        lineSearch.searchDirection = Matrix(zeros(x_.flat.count))
        var done = false
        
        // function and squared norm of gradient values;
        var fnew : Double
        var fold : Double
        var gold2 : Double
        var fdiff : Double
        
        // classical initial value for line-search step
        var t = 1.0
        // Set gradient g at the size of the optimization problem
        // search direction
        var sz = lineSearch.searchDirection.flat.count
        
        var prevGradient = Matrix(zeros(sz))
        var d = Matrix(zeros(sz))
        var sddiff = Matrix(zeros(sz))
        var direction = Matrix(zeros(sz))
        
        // Initialize cost function, gradient prevGradient and search direction
        problem.functionValue = problem.valueAndGradient(grad: &prevGradient, parameters:  x_)
        problem.squaredNorm = dotinside(lhs: prevGradient, rhs: prevGradient)
        
        var temp = Matrix(prevGradient)
        for i in 0..<temp.flat.count {
            temp[i] *= -1
        }
        lineSearch.searchDirection = temp
        
        var first_time = true
        // Loop over iterations
        repeat {
            // Linesearch
            if (!first_time) {
                prevGradient = lineSearch.lastGradient()
            }
            
            t = lineSearch.search(problem: &problem, endCriteriaType: &ecType, endCriteria: endCriteria, initialValue: t)
            
            // don't throw: it can fail just because maxIterations exceeded
            if (lineSearch.succeed)
            {
                // Updates
                
                // New point
                x_ = lineSearch.lastX()
                // New function value
                fold = problem.functionValue
                problem.functionValue = lineSearch.lastFunctionValue()
                // New gradient and search direction vectors
                
                // orthogonalization coef
                gold2 = problem.squaredNorm
                problem.squaredNorm = lineSearch.lastGradientNorm2()
                
                // conjugate gradient search direction
                direction = getUpdatedDirection(problem: &problem, gold2: gold2, gradient: prevGradient);
                
                sddiff = direction - lineSearch.searchDirection
                lineSearch.searchDirection = direction
                
                // Now compute accuracy and check end criteria
                // Numerical Recipes exit strategy on fx (see NR in C++, p.423)
                fnew = problem.functionValue
                fdiff = 2.0 * abs(fnew-fold) / (abs(fnew) + abs(fold)) // + 1e-100)
                if (fdiff < ftol ||
                    endCriteria.checkMaxIterations(iteration: iterationNumber_, endCriteriaType: &ecType)) {
                    endCriteria.checkStationaryFunctionValue(fxOld: 0.0, fxNew: 0.0,
                            stationaryStateIterations: &maxStationaryStateIterations_, endCriteriaType: &ecType);
                    endCriteria.checkMaxIterations(iteration: iterationNumber_, endCriteriaType: &ecType)
                        return ecType
                }
                problem.currentValue = x_      // update problem current value
                iterationNumber_ += 1         // Increase iteration number
                first_time = false
            } else {
                done = true
            }
        } while (!done)
        
        problem.currentValue = x_
        return ecType
    }
    
    func getUpdatedDirection( problem : inout Problem, gold2 : Double, gradient : Matrix) -> Matrix {
        return Matrix(Array(repeating: 0.0, count: 0))
    }
}

func dotinside(lhs: Matrix, rhs: Matrix) -> Double {
    return dot(lhs.flat, rhs.flat)
}
