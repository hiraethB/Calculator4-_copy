//
//  ViewController.swift
//  Calculator4
//
//  Created by Борис Винник on 25.09.17.
//  Copyright © 2017 GRIAL. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    var userInTheMiddleOfTyping = false
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userInTheMiddleOfTyping { // это не первый символ?
            let textCurrentlyInDisplay = display.text! // не первый
            if !(textCurrentlyInDisplay.contains (".")) || (digit != ".") {
                display.text = textCurrentlyInDisplay + digit
            }
        }
        else { // это первый вводимый символ с цифровой клавиатуры
            display.text = digit
           // if digit != "." {
                userInTheMiddleOfTyping = true
           // }
        }
    }
    var displayValue : Double { // вычисляемое свойство
        get {
            return Double ( display.text!)! // (вычислить) преобразовать получаемое значение в Double //???? случай ввода(.π.) или (π.π)
            // ошибка происходит из-за предположения, что строку на дисплее всегда можно интерпретировать как Double.
        }
        set {
            display.text = String( newValue)
        }
    }
    private var brain = CalculatorBrain()
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping { // Если в середине ввода, то при вводе операции
            brain.setOperand(displayValue) //  установить operand
            userInTheMiddleOfTyping = false // сбросить флаг "середина ввода" в false
        }
        if let mathematicalSymbol = sender.currentTitle { // выполнение операции в начале ввода
            brain.performOperation(mathematicalSymbol) // передача символа операции для вычисления
        }
        if let result = brain.result { // получение результата операции
            displayValue = result
        }
    }
}
