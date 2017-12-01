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
    
    @IBOutlet weak var radDeg: UILabel!
    @IBOutlet weak var sin: UIButton!
    @IBOutlet weak var cos: UIButton!
    @IBOutlet weak var tan: UIButton!
    
    @IBOutlet weak var degreese: UIButton!
    @IBAction func degRad(_ sender: UIButton) {
        if sender.currentTitle != "Deg" {
            sender.setTitle("Deg", for: .normal)
            radDeg.text = "  rad"
        } else {
            sender.setTitle("rad", for: .normal)
            radDeg.text = ""
        }
    }
    
    private var brain = CalculatorBrain()
    private var inverse = false
    @IBAction func inverseFunction() {
        inverse = !inverse
        if inverse {
            brain.performOperation("Inv")
            tan.setTitle( "atan", for: .normal)
            sin.setTitle( "asin", for: .normal)
            cos.setTitle( "acos", for: .normal)
        } else {
            brain.performOperation("Dir")
            tan.setTitle( "tan", for: .normal)
            sin.setTitle( "sin", for: .normal)
            cos.setTitle( "cos", for: .normal)
        }
    }
    
    let decimalSeparator = numberFormatter.decimalSeparator!
    @IBOutlet weak var point: UIButton! {
        didSet {
            point.setTitle( numberFormatter.decimalSeparator, for: .normal)
        }
    }
   
    private var userInTheMiddleOfTyping = false
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if !userInTheMiddleOfTyping {
            display.text = digit != decimalSeparator ? digit :  "0" + digit
            userInTheMiddleOfTyping = true
        } else {
            let textCurrentlyInDisplay = display.text!
            if !textCurrentlyInDisplay.contains( decimalSeparator) || digit != decimalSeparator {
                display.text = textCurrentlyInDisplay + digit
            }
        }
        if !brain.resultIsPending { //5+6=7 “… “
            sequence.text = "..."
        }
    }
    
    @IBAction func backSpace() {
        if display.text != nil && userInTheMiddleOfTyping {
            guard display.text!.count <= 1  else {
                display.text!.removeLast()
                return
            }
            displayValue = 0
            userInTheMiddleOfTyping = false
        }
    }
    
    private var displayValue : Double? {
        get {
            if let text = display.text, let value = numberFormatter.number( from: text) as? Double
            { return value }
            return nil
        } set {
            if let new = newValue {
                display.text = numberFormatter.string(from: NSNumber( value: new))
            }
            if let description = brain.description {
                sequence.text = description + (brain.resultIsPending ? "..." : "=")
            }
        }
    }
    //===================================================
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            userInTheMiddleOfTyping = false
            if displayValue != nil {
                brain.setOperand( displayValue!)
            }
        }
        brain.performOperation(sender.currentTitle ?? "")
        displayValue = brain.result
    }
    
    @IBAction func reset() {
        displayValue = 0
        userInTheMiddleOfTyping = false
        sequence.text = String()
        brain.reset()
    }
}


