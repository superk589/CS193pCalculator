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

struct CalculatorBrain: CustomStringConvertible {
    
    typealias Operand = (value: Double, text: String)
    
    private var accumulator: Operand?
    
    private var internalSequence = [OperationSequenceItem]()
    
    private struct OperationSequenceItem {
        var operand: Operand?
        var symbol: String?
    }
    
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
            internalSequence.append(OperationSequenceItem.init(operand: nil, symbol: symbol))
            switch operation {
            case .constant(let constant):
                accumulator = (constant, "\(symbol)")
            case .binaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending {
                        performPendingBinaryOperation()
                    }
                    pendingBinaryOperation = PendingBinaryOperation.init(function: function, firstOperand: accumulator!, symbol: symbol)
                    accumulator = nil
                }
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulator = (function(accumulator!.value), "\(symbol)(\(accumulator!.text))")
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation?.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private struct PendingBinaryOperation {
        var function: BinaryOpertion
        var firstOperand: Operand
        let symbol: String
        mutating func perform(with secondOperand: Operand) -> Operand {
            return (function(firstOperand.value, secondOperand.value), "\(firstOperand.text) \(symbol) \(secondOperand.text)")
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        setOperand((operand, String(operand)))
    }
    
    mutating func setOperand(_ operand: Operand) {
        accumulator = operand
        internalSequence.append(OperationSequenceItem.init(operand: accumulator, symbol: nil))
    }
    
    var variables = [String: Double]()
    
    mutating func setOperand(variable named: String) {
        if let value = variables[named] {
            accumulator = (value, named)
        } else {
            accumulator = (0, named)
        }
        internalSequence.append(OperationSequenceItem.init(operand: accumulator, symbol: nil))
    }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String) {
        var brain = CalculatorBrain()
        if variables != nil {
            brain.variables = variables!
        }
        let sequence = internalSequence
        for item in sequence {
            if var operand = item.operand {
                if let newValue = variables?[operand.text] {
                    operand.value = newValue
                }
                brain.setOperand(operand)
            }
            if let symbol = item.symbol {
                brain.performOperation(symbol)
            }
        }
        return (brain.result, brain.resultIsPending, brain.description)
    }
    
    var result: Double? {
        get {
            return accumulator?.value ?? pendingBinaryOperation?.firstOperand.value
        }
    }

    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        variables.removeAll()
        internalSequence.removeAll()
    }
    
    mutating func undo() {
        if internalSequence.count > 0 {
            internalSequence.removeLast()
        }
    }
    
    var description: String {
        if resultIsPending {
            if accumulator != nil {
                if accumulator!.text != String(accumulator!.value) {
                    return "\(pendingBinaryOperation!.firstOperand.text) \(pendingBinaryOperation!.symbol) \(accumulator!.text)"
                }
            }
            return "\(pendingBinaryOperation!.firstOperand.text) \(pendingBinaryOperation!.symbol) ..."
        } else {
            return "\(accumulator?.text ?? "0") = "
        }
    }
}
