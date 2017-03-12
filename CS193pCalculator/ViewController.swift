//
//  ViewController.swift
//  CS193pCalculator
//
//  Created by zzk on 2017/2/28.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var userIsInTheMiddleOfTyping = false
    
    @IBOutlet weak var variable: UILabel!
    @IBOutlet weak var sequence: UILabel!
   
    @IBOutlet weak var display: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            self.display.text = String(newValue)
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (display.text?.contains(".") ?? false) && digit == "." {
                return
            } else {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    @IBAction func touchOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
        }
        evaluate()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        display.text = "0"
        userIsInTheMiddleOfTyping = false
        sequence.text = ""
        variable.text = ""
    }
    
    @IBAction func touchVariable(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle ?? "")
        display.text = sender.currentTitle ?? ""
    }
    
    @IBAction func touchToEvaluate(_ sender: UIButton) {
        brain.variables["M"] = displayValue
        variable.text = "M = \(displayValue)"
        evaluate()
    }
    
    @IBAction func touchUndo(_ sender: UIButton) {
        brain.undo()
        evaluate()
    }
    
    private func evaluate() {
        let (result, _, description) = brain.evaluate(using: brain.variables)
        if result != nil {
            sequence.text = description
            displayValue = result!
        }
        userIsInTheMiddleOfTyping = false
    }
}

