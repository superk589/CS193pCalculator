//
//  CalculatorBrain.swift
//  CS193pCalculator
//
//  Created by zzk on 2017/2/28.
//  Copyright © 2017年 zzk. All rights reserved.
//

import Foundation

typealias BinaryOpertion = (Double, Double) -> Double
typealias UnaryOperation = (Double) -> Double

struct CalculatorBrain {
    
    private var accumulator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation(UnaryOperation)
        case binaryOperation(BinaryOpertion)
        case equals
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "±": Operation.unaryOperation(-),
        "×": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "=": Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let constant):
                accumulator = constant
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOpertion = PendingBinaryOperation.init(function: function, firstOperand: accumulator!)
                }
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    private var pendingBinaryOpertion: PendingBinaryOperation?
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOpertion != nil && accumulator != nil {
            accumulator = pendingBinaryOpertion!.perform(with: accumulator!)
            pendingBinaryOpertion = nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: BinaryOpertion
        let firstOperand: Double
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
}
