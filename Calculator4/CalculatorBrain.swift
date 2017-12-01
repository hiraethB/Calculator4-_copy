//
//  CalculatorBrain.swift
//  Calculator4
//
//  Created by Boris V on 25.09.17.
//  Copyright © 2017 GRIAL. All rights reserved.
//

import Foundation

let numberFormatter: NumberFormatter = {
    let formatter = NumberFormatter ()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    formatter.locale = NSLocale.current
    return formatter
} ()

struct CalculatorBrain {
    //================================
    private enum Operation {
        case invFunctions ( Bool)
        case directFunctions ( Bool)
        case rad (Double)
        case deg (Double)
        case unaryOperation (( Double) -> Double, ((String) -> String)?)
        
        //================================
        case constant(Double)
        case equals
        case randOperation(() -> Double,String)
        case binaryOperation ((Double, Double) -> Double, ((String, String) -> String)?, Int)
    }
    //======================================================
    private var operations = [
        "Inv" : Operation.invFunctions( true),
        "Dir" : Operation.directFunctions( false),
        "asin" : Operation.unaryOperation( asin, nil),
        "acos" : Operation.unaryOperation( acos, nil),
        "atan" : Operation.unaryOperation( atan, nil),
        "sin" : Operation.unaryOperation( sin, nil),
        "cos" : Operation.unaryOperation( cos, nil),
        "tan": Operation.unaryOperation( tan, nil),
        "rad" : Operation.deg( .pi/180 ),
        "Deg" : Operation.rad ( 1.0),
        "π" : Operation.constant( Double.pi),
        "e" : Operation.constant( M_E),
        "√" : Operation.unaryOperation( sqrt, { "√(" + $0 + ")" }),
        "∛" : Operation.unaryOperation({ pow($0, 1.0/3)}, { "∛(" + $0 + ")" }),
        "±" : Operation.unaryOperation({ -$0 }, { "±(" + $0 + ")" }),
        "x²" : Operation.unaryOperation({ $0*$0 }, { "(" + $0 + ")²" }),
        "x³" : Operation.unaryOperation({ pow($0, 3)}, { "(" + $0 + ")³" }),
        "×" : Operation.binaryOperation( *, nil,1),
        "÷" : Operation.binaryOperation( /, nil,1),
        "+" : Operation.binaryOperation( +, nil,0),
        "-" : Operation.binaryOperation( -, nil,0),
        "Rand" : Operation.randOperation({ Double(arc4random_uniform(UInt32.max)) / Double(UInt32.max)},"Rand"),
        "=" : Operation.equals,
    ]
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        var prevPrecedence: Int
        var precedence: Int
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
        func buildDescription (with secondOperand: String) -> String {
            var new = descriptionOperand
            if prevPrecedence < precedence {
                new = "(" + new + ")"
            }
            return descriptionFunction ( new, secondOperand)
        }
    }
    
    private var prevPrecedence = Int.max
    private var pendingBinaryOperation: PendingBinaryOperation?
    //==================================================================
    private var accumulator: ( value: Double? , description: String?,
        kTrigonometry: Double, inverseFunction: Bool) = (0,"", 1, false)
    //=IN===============================================================
    mutating func performOperation (_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .invFunctions(let value) :
                accumulator.inverseFunction = value
            case .directFunctions(let value) :
                accumulator.inverseFunction = value
            case .rad(let value) :
                accumulator.kTrigonometry = value
            case .deg (let value) :
                accumulator.kTrigonometry = value
            case .unaryOperation (let function, var descriptionFunction):
                guard accumulator.value != nil else { return}
                if  descriptionFunction != nil {
                    accumulator.value = function( accumulator.value!)
                } else {
                    if accumulator.inverseFunction { // обратные функции
                        accumulator.value = function( accumulator.value!) * 1/accumulator.kTrigonometry
                    } else {
                        accumulator.value = function( accumulator.value! * accumulator.kTrigonometry)
                    }
                    if accumulator.kTrigonometry != 1 { //градусы
                        descriptionFunction = {symbol + "d(" + $0 + ")"}
                    } else { // радианы
                        descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                }
                accumulator.description = descriptionFunction!( accumulator.description!)
                
            case .binaryOperation( let function, var descriptionFunction, let precedence):
                performPendingBinaryOperation()
                // отложенная бинарная операция
                if accumulator.value != nil {
                    if  descriptionFunction == nil {
                        descriptionFunction = {$0 + symbol + $1}
                    }
                    // Запомнить первый операнд, операцию, их описания, описание их последовательности и приоритет операции
                    pendingBinaryOperation = PendingBinaryOperation (function:function,
                                                                     firstOperand:accumulator.value!,
                                                                     descriptionFunction: descriptionFunction!,
                                                                     descriptionOperand: accumulator.description!,
                                                                     prevPrecedence: prevPrecedence,
                                                                     precedence: precedence)
                    // операция выполнена
                    accumulator.value = nil
                    accumulator.description = nil
                }
            case .constant(let value):
                accumulator.value = value
                accumulator.description = symbol
            case .equals:
                performPendingBinaryOperation() // к выполнению бинарной операции
                
            case .randOperation (let function, let descriptionValue):
                accumulator.value = function()
                accumulator.description = descriptionValue
            }
        }
    }
    
    mutating func  performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            accumulator.value =  pendingBinaryOperation!.perform(with: accumulator.value!)
            // вызов функции контроля приоритетов бинарных операций и запись строки описания операндов и функций после выполнения бинарной операции
            accumulator.description = pendingBinaryOperation!.buildDescription(with: accumulator.description!)
            // запись приоритета последней бинарной операции для сравнения с приоритетом будущей
            prevPrecedence = pendingBinaryOperation!.precedence
            
            pendingBinaryOperation = nil // отложенная бинарная операция выполнена, сбросить флаг
        }
    }
    
    mutating func setOperand (_ operand: Double){
        accumulator.value = operand
        if let new = accumulator.value {
            accumulator.description = numberFormatter.string(from: NSNumber(value: new)) ?? ""
        }
    }
    
    mutating func reset() {
        setOperand(0)
        pendingBinaryOperation = nil
    }
    //=OUT============================================
    var result: Double? {
        return accumulator.value
    }
    var description: String? {
        if pendingBinaryOperation == nil {
            return accumulator.description
        } else {
            return pendingBinaryOperation!.descriptionFunction(
                pendingBinaryOperation!.descriptionOperand,accumulator.description ?? "")
        }
    }
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
}

