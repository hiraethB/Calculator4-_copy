//
//  CalculatorBrain.swift
//  Calculator4
//
//  Created by Boris V on 25.09.17.
//  Copyright © 2017 GRIAL. All rights reserved.
//

import Foundation
private struct PendingBinaryOperation { // структура для запоминания свойств отложенной бинарной операции
    let function: (Double, Double) -> Double
    let firstOperand: Double // сохранение первого оператора бинарной функции
    var description: String
    func perform(with secondOperand: Double) -> Double {
        return function(firstOperand, secondOperand)
    }
}
let numberFormatter: NumberFormatter = { // Форматтер, который преобразует числовые значения и их текстовые представления, свойство класса NumberFormatter
    let formatter = NumberFormatter () // создаем методы
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 6
    formatter.locale = NSLocale.current
    return formatter
} ()
struct CalculatorBrain {
    var accumulator: ( value: Double?, description: String) = ( nil, "")
    mutating func initialization () {
        setOperand(0.0)
        pendingBinaryOperation = nil
        resultIsPending = false
    }
    enum Operation {
        case constant(Double)
        case unaryOperation(( Double) -> Double)
        case binaryOperation ((Double, Double) -> Double)
        case equals
        case randOperation(() -> Double)
    }
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "∛" : Operation.unaryOperation{pow($0, 1.0/3)},
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "±" : Operation.unaryOperation{ -$0 },
        "×" : Operation.binaryOperation{ $0 * $1 },
        "÷" : Operation.binaryOperation{ $0 / $1 },
        "+" : Operation.binaryOperation{ $0 + $1 },
        "-" : Operation.binaryOperation{ $0 - $1 },
        "x²" : Operation.unaryOperation{ $0*$0 },
        "x³" : Operation.unaryOperation{ pow($0,3) },
        "=" : Operation.equals,
        "Rand" : Operation.randOperation{ Double(arc4random()) / Double(UInt32.max) } // Генерирует случайное число с плавающей точкой от 0 до 1 двойной точности
    ]
    var resultIsPending = false //флаг отложенной бинарной операции
    private var pendingBinaryOperation: PendingBinaryOperation? // отложенная бинарная операция
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .binaryOperation(let function):
                performPendingBinaryOperation() // согласно (6х5х4х3=) hw.hint 1.7
                if accumulator.value != nil { // есть значение (запомнить первый операнд и операцию с описанием их последовательности)
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator.value!, description: accumulator.description + symbol)
                    if (symbol == "×" || symbol == "÷") {
                        pendingBinaryOperation!.description = ("(" + accumulator.description + ")" + symbol) // добавить "(" и ")" в описание последовательности для "×" или "÷"
                    }
                accumulator = (nil, pendingBinaryOperation!.description)
                resultIsPending = true
                }
            case .constant(let value):
                accumulator = (value, symbol)
            case .equals:
                performPendingBinaryOperation() // к выполнению бинарной операции
            case .unaryOperation(let function):
                var relation: String
                if accumulator.value != nil {
                    if resultIsPending  {
                        relation = pendingBinaryOperation!.description + symbol + "(" + accumulator.description + ")"
                        pendingBinaryOperation!.description = String() // сбросить описание последовательности в буфере отложенной бинарной операции
                    } else { // нет отложенной бинарной операции
                        relation = symbol + "(" + accumulator.description + ")"
                    }
                    accumulator = (function(accumulator.value!), relation)
                }
            case .randOperation (let function):
                accumulator = (function(), symbol)
            }
        }
    }
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator.value != nil {
            accumulator = (pendingBinaryOperation!.perform( with: accumulator.value!), pendingBinaryOperation!.description + accumulator.description )
            pendingBinaryOperation = nil
            resultIsPending = false
        }
    }
    mutating func setOperand(_ operand: Double) { // передача операнда из ViewController во время выполнения операции
        accumulator.value = operand
        if let value = accumulator.value { // есть операнд?
            accumulator.description = numberFormatter.string(from: NSNumber(value: value)) ?? "..."
        }
    }
}
