
//
//  GraphView.swift
//  CS193pCalculator
//
//  Created by zzk on 2017/3/12.
//  Copyright © 2017年 zzk. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func graphView(_ graphView: GraphView, yValueForGiven x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 50 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var origin: CGPoint? { didSet { setNeedsDisplay() } }
    var model = CalculatorBrain() { didSet { setNeedsDisplay() } }
    @IBInspectable
    var color = UIColor.blue  { didSet { setNeedsDisplay() } }

    
    var axesCenter: CGPoint {
        get {
            return origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        }
        set {
            origin = newValue
        }
    }
    
    weak var delegate: GraphViewDataSource?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private var axexDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        axexDrawer.drawAxes(in: bounds, origin: axesCenter, pointsPerUnit: pointsPerUnit)
        color.set()
        generatePath().stroke()
    }
    
    private func generatePath() -> UIBezierPath {
        var firstLoop = true
        let path = UIBezierPath()
        for x in stride(from: bounds.minX, to: bounds.maxX, by: 2) {
            if let y = delegate?.graphView(self, yValueForGiven: getXValue(CGFloat(x))), checkPointValidation(point: CGPoint(x: x, y: getYposition(y))) {
                if firstLoop {
                    path.move(to: CGPoint.init(x: CGFloat(x), y: getYposition(y)))
                    firstLoop = false
                } else {
                    path.addLine(to: CGPoint.init(x: CGFloat(x), y: getYposition(y)))
                }
            }
        }
        path.lineWidth = 2
        return path
    }
    
    private func checkPointValidation(point: CGPoint) -> Bool {
        return self.bounds.contains(point)
    }
    
    private func getXValue(_ position: CGFloat) -> CGFloat {
        return (position - axesCenter.x) / pointsPerUnit
    }
    
    private func getYposition(_ yValue: CGFloat) -> CGFloat {
        return axesCenter.y - yValue * pointsPerUnit
    }
    
}
