//
//  MatrixTests.swift
//  LASwift
//
//  Created by Alexander Taraymovich on 28/02/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Darwin

//import Quick
//import Nimble
import LASwift

func testTrace() {
    let m1 = Matrix([[1.0, 0.0, 2.0],
                     [-1.0, 5.0, 0.0],
                     [0.0, 3.0, -9.0]])
    print("Trace of \n\(m1) = \(trace(m1))")
    print("Transpose of \n\(m1) = \(transpose(m1))")
}
