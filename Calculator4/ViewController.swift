//
//  ViewController.swift
//  Calculator4
//
//  Created by Boris V on 25.09.17.
//  Copyright © 2017 GRIAL. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var sequence: UILabel!
    private var userInTheMiddleOfTyping = false // флаг начатого и незаконченного цифрового ввода
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if !(textCurrentlyInDisplay.contains (".")) || (digit != ".") {
                display.text = textCurrentlyInDisplay + digit
            }
        } else { // это первый вводимый символ с цифровой клавиатуры
            display.text = digit
            userInTheMiddleOfTyping = true
        }
        if !brain.resultIsPending { // пример 5+6=7 будет показано “… “ ( 7 на display)
            sequence.text = "..."
       }
    }
    private var displayValue : Double? { // разрешение предположения профессора (всегда ли строку цифрового ввода можно интерпретировать как Double)
        get {
            if display.text != nil { // введено число ?
                return Double (display.text!) // вернуть Double
            }
                return nil // не число, вернуть опционалу "not set"
        } set {
            if let new = newValue {
                display.text = numberFormatter.string(from: NSNumber( value: new))
            }
        }
    }
    private var brain = CalculatorBrain()
    @IBAction func performOperation(_ sender: UIButton) { // выполнить операцию
        if userInTheMiddleOfTyping { // Если в середине ввода числа, то при вводе операции
            userInTheMiddleOfTyping = false // зафиксировать окончание ввода операнда
            if displayValue != nil {
                brain.setOperand( displayValue!) //  установить операнд и описание операции
            }
        }
        if let mathematicalSymbol = sender.currentTitle { // символ операции определён
            brain.performOperation(mathematicalSymbol) // передать для вычисления в Модель
        }
        displayValue = brain.accumulator.value // получение результата вычислений
        sequence.text = brain.accumulator.description + (brain.resultIsPending ? "..." : "=")
    }
    @IBAction func reset(_ sender: UIButton) {
        displayValue = 0
        userInTheMiddleOfTyping = false
        sequence.text = String() // пустая строка ленты
        brain.reset ()
    }
    @IBAction func backSpace(_ sender: UIButton) {
        if display.text != nil && userInTheMiddleOfTyping {
            if display.text!.characters.count > 1 { // количество символов строки дисплея
                display.text!.characters.removeLast() // стирает крайний правый, последний из введенных, символ цифры или точки
            } else {
                displayValue = 0
                userInTheMiddleOfTyping = false
            }
        }
    }
}


