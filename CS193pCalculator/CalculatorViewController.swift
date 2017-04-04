//
//  ViewController.swift
//  CS193pCalculator
//
//  Created by zzk on 2017/2/28.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

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
            if newValue != Double.nan || newValue != .infinity || ceil(newValue) != newValue {
                self.display.text = String(newValue)
            } else {
                self.display.text = String(Int(newValue))
            }
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
        if userIsInTheMiddleOfTyping {
            if let count = display.text?.characters.count, count > 1 {
                let newString = display.text!.substring(to: display.text!.index(before: display.text!.endIndex))
                display.text = newString
            } else {
                displayValue = 0
                userIsInTheMiddleOfTyping = false
            }
        } else {
            brain.undo()
            evaluate()
        }
    }
    
    private func evaluate() {
        let (result, _, description) = brain.evaluate(using: brain.variables)
        if result != nil {
            sequence.text = description
            displayValue = result!
        }
        userIsInTheMiddleOfTyping = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination.contents as? GraphViewController {
            vc.brain = self.brain
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // if brain is pending should not segue to graph view
        if identifier == "ShowGraph" && brain.resultIsPending {
            return false
        }
        return true
    }
    
    
    private func showSizeClasses() {
        print("width " + traitCollection.horizontalSizeClass.description + " height " + traitCollection.verticalSizeClass.description)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSizeClasses()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (coordinator) in
            self.showSizeClasses()
        }, completion: nil)
    }
}


extension UIUserInterfaceSizeClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compact:
            return "Compact"
        case .regular:
            return "Regular"
        case .unspecified:
            return "??"
        }
    }
}
