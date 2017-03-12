//
//  GraphViewController.swift
//  CS193pCalculator
//
//  Created by zzk on 2017/3/12.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    var brain: CalculatorBrain? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.splitViewController?.delegate = self
    }
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(handlePanGesture(_:)))
            graphView.addGestureRecognizer(panGesture)
            let pinchGesture = UIPinchGestureRecognizer.init(target: self, action: #selector(handlePinchGesture(_:)))
            graphView.addGestureRecognizer(pinchGesture)
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
            tapGesture.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGesture)
            graphView.delegate = self
            updateUI()
        }
    }
    
    private func updateUI() {
        graphView?.setNeedsDisplay()
        if let description = brain?.description.trimmingCharacters(in: [" ", "="]) {
            display?.text = "y = \(description)"
        }
    }
    
    // MARK: Gesture Handlers
    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .changed, .ended:
            let translation = panGesture.translation(in: graphView)
            graphView.origin = CGPoint(x: graphView.axesCenter.x + translation.x / graphView.pointsPerUnit, y: graphView.axesCenter.y + translation.y / graphView.pointsPerUnit)
        default:
            break
        }
    }
    
    func handleTapGesture(_ tapGesture: UIPanGestureRecognizer) {
        let touchPoint = tapGesture.location(in: self.graphView)
        graphView.axesCenter = CGPoint(x: touchPoint.x, y: touchPoint.y)
    }

    func handlePinchGesture(_ pinchGesture: UIPinchGestureRecognizer) {
        let scale = pinchGesture.scale
        graphView.pointsPerUnit *= scale
        pinchGesture.scale = 1
    }
}

extension GraphViewController: GraphViewDataSource {
    func graphView(_ graphView: GraphView, yValueForGiven x: CGFloat) -> CGFloat? {
        if brain != nil {
            brain!.variables["M"] = Double(x)
            let (result, isPending, _) = brain!.evaluate(using: brain!.variables)
            if !isPending && result != nil {
                return CGFloat(result!)
            }
        }
        return nil
    }
}


extension GraphViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
