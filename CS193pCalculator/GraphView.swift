
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
    
    private var axexDrawer = AxesDrawer()
    
    override func draw(_ rect: CGRect) {
        axexDrawer.drawAxes(in: bounds, origin: axesCenter, pointsPerUnit: pointsPerUnit)
        color.set()
        let paths = generatePaths()
        for path in paths {
            path.stroke()
        }
    }
    
    private func generatePaths() -> [UIBezierPath] {
        
        var paths = [UIBezierPath]()
        
        var firstLoop = true
        var path = UIBezierPath()
        paths.append(path)
        
        for xPoint in stride(from: bounds.minX, to: bounds.maxX, by: 2) {
            if let yValue = delegate?.graphView(self, yValueForGiven: getXValue(CGFloat(xPoint))) {
                let yPoint = getYposition(yValue)
                let point = CGPoint.init(x: xPoint, y: yPoint)
                guard checkValidation(of: point) else {
                    if !firstLoop {
                        path = UIBezierPath()
                        paths.append(path)
                        firstLoop = true
                    }
                    continue
                }
                if firstLoop {
                    path.move(to: point)
                    firstLoop = false
                } else {
                    path.addLine(to: point)
                }
            }
        }
        return paths
    }
    
    private func checkValidation(of point: CGPoint) -> Bool {
        return self.bounds.contains(point)
    }
    
    private func getXValue(_ position: CGFloat) -> CGFloat {
        return (position - axesCenter.x) / pointsPerUnit
    }
    
    private func getYposition(_ yValue: CGFloat) -> CGFloat {
        return axesCenter.y - yValue * pointsPerUnit
    }
    
}
