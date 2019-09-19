//
//  HUDRoundProgressView.swift
//  KProgressHUD
//
//  Created by raniys on 2019/5/5.
//  Copyright © 2019 kid17. All rights reserved.
//

import UIKit

/// A progress view for showing definite progress by filling up a circle (pie chart).
open class HUDRoundProgressView: HUDProgressView {
    
    /**
     * Indicator progress color.
     * Defaults to white [UIColor whiteColor].
     */
    public var progressTintColor: UIColor? {
        set {
            guard newValue != _progressTintColor else { return }
            _progressTintColor = newValue
        }
        get {
            return _progressTintColor
        }
    }
    
    /**
     * Indicator background (non-progress) color.
     * Only applicable on iOS versions older than iOS 7.
     * Defaults to translucent white (alpha 0.1).
     */
    public var backgroundTintColor: UIColor? {
        set {
            guard newValue != _backgroundTintColor else { return }
            _backgroundTintColor = newValue
        }
        get {
            return _backgroundTintColor
        }
    }
    
    /// Display mode - NO = round or YES = annular. Defaults to round.
    public var annular: Bool = false
    
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 37, height: 37)
    }
    
    
    private var _progressTintColor: UIColor? { didSet { setNeedsDisplay() } }
    private var _backgroundTintColor: UIColor? { didSet { setNeedsDisplay() } }
    
    
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 37, height: 37))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        _progressTintColor = UIColor(white: 1, alpha: 1)
        _backgroundTintColor = UIColor(white: 1, alpha: 0.1)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        
        // Draw background
        let lineWidth: CGFloat = 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let pi = CGFloat(Double.pi)
        
        let backgroundTintColor = _backgroundTintColor ?? UIColor(white: 1, alpha: 0.1)
        let progressTintColor = _progressTintColor ?? UIColor(white: 1, alpha: 1)
        
        if annular {
            let radius: CGFloat = (bounds.size.width - lineWidth) / 2
            let startAngle: CGFloat = -(pi / 2) // 90 degrees
            var endAngle: CGFloat = 2 * pi + startAngle
            
            let processBackgroundPath = UIBezierPath()
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = .butt
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            backgroundTintColor.set()
            processBackgroundPath.stroke()
            
            // Draw progress
            endAngle = progress * 2 * pi + startAngle
            
            let processPath = UIBezierPath()
            processPath.lineWidth = lineWidth
            processPath.lineCapStyle = .square
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            
            progressTintColor.set()
            processPath.stroke()
            
        } else {
            let context = UIGraphicsGetCurrentContext()
            let circleRect = bounds.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
            
            progressTintColor.setStroke()
            backgroundTintColor.setFill()

            context?.setLineWidth(lineWidth)
            context?.strokeEllipse(in: circleRect)
            
            // Draw progress
            let processPath = UIBezierPath()
            processPath.lineWidth = lineWidth * 2
            processPath.lineCapStyle = .butt

            let radius = bounds.width / 2 - processPath.lineWidth / 2
            let startAngle: CGFloat = -(pi / 2) // 90 degrees
            let endAngle = progress * 2 * pi + startAngle
            
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

            // Ensure that we don't get color overlapping when _progressTintColor alpha < 1.f.
            context?.setBlendMode(.copy)

            progressTintColor.set()
            processPath.stroke()
        }
        
    }
    
}
