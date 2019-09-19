//
//  HUDBarProgressView.swift
//  KProgressHUD
//
//  Created by raniys on 2019/5/5.
//  Copyright © 2019 kid17. All rights reserved.
//

import UIKit

/// A flat bar progress view. 
open class HUDBarProgressView: HUDProgressView {
    
    /**
     * Bar border line color.
     * Defaults to white.
     */
    public var lineColor: UIColor?
    
    /**
     * Bar progress color.
     * Defaults to white.
     */
    public var progressColor: UIColor? {
        set {
            guard newValue != _progressColor else { return }
            _progressColor = newValue
        }
        get {
            return _progressColor
        }
    }
    
    /**
     * Bar background color.
     * Defaults to clear.
     */
    public var progressRemainingColor: UIColor {
        set {
            guard newValue != _progressRemainingColor else { return }
            _progressRemainingColor = newValue
        }
        get {
            return _progressRemainingColor
        }
    }
  
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: 120, height: 10)
    }
    
    private var _progressColor: UIColor? { didSet { setNeedsDisplay() } }
    private var _progressRemainingColor: UIColor = .clear { didSet { setNeedsDisplay() } }
    
    public convenience init() {
        self.init(frame: CGRect(x: 0, y: 0, width: 120, height: 10))
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        lineColor = .white
        _progressColor = .white
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    open override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let borderLineWidth: CGFloat = 2
        
        context?.setLineWidth(borderLineWidth)
        let strokeColor = lineColor ?? UIColor.white
        context?.setStrokeColor(strokeColor.cgColor)
        context?.setFillColor(_progressRemainingColor.cgColor)
        
        // Draw background and Border
        let height = rect.size.height
        let width = rect.size.width
        var radius = height / 2 - borderLineWidth
        
        context?.move(to: CGPoint(x: borderLineWidth, y: height / 2))
        
        context?.addArc(tangent1End: CGPoint(x: borderLineWidth, y: borderLineWidth), tangent2End: CGPoint(x: radius + borderLineWidth, y: borderLineWidth), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: width - borderLineWidth, y: borderLineWidth), tangent2End: CGPoint(x: width - borderLineWidth, y: height / 2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: width - borderLineWidth, y: height - borderLineWidth), tangent2End: CGPoint(x: width - radius - borderLineWidth, y: height - borderLineWidth), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: borderLineWidth, y: height - borderLineWidth), tangent2End: CGPoint(x: borderLineWidth, y: height / 2), radius: radius)
        
        context?.drawPath(using: .stroke)
        
    
        // Progress in the middle area
        let fillColor = _progressColor ?? UIColor.white
        context?.setFillColor(fillColor.cgColor)
        radius = radius - borderLineWidth
        let amount = progress * width
        let borderWidth = borderLineWidth * 2

        if amount >= radius + borderWidth, amount <= width - radius - borderWidth {
            context?.move(to: CGPoint(x: borderWidth, y: height / 2))
            context?.addArc(tangent1End: CGPoint(x: borderWidth, y: borderWidth), tangent2End: CGPoint(x: radius + borderWidth, y: borderWidth), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: borderWidth))
            context?.addLine(to: CGPoint(x: amount, y: radius + borderWidth))

            context?.move(to: CGPoint(x: borderWidth, y: height / 2))
            context?.addArc(tangent1End: CGPoint(x: borderWidth, y: height - borderWidth), tangent2End: CGPoint(x: radius + borderWidth, y: height - borderWidth), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: height - borderWidth))
            context?.addLine(to: CGPoint(x: amount, y: radius + borderWidth))

            context?.fillPath()

        } else if amount > radius + borderWidth {

            let x = amount - (width - radius - borderWidth)

            context?.move(to: CGPoint(x: borderWidth, y: height / 2))
            context?.addArc(tangent1End: CGPoint(x: borderWidth, y: borderWidth), tangent2End: CGPoint(x: radius + borderWidth, y: borderWidth), radius: radius)
            context?.addLine(to: CGPoint(x: width - radius - borderWidth, y: borderWidth))

            var angle = -acos(x / radius)
            if angle.isNaN { angle = 0 }
            context?.addArc(center: CGPoint(x: width - radius - borderWidth, y: height / 2), radius: radius, startAngle: CGFloat(Double.pi), endAngle: angle, clockwise: false)
            context?.addLine(to: CGPoint(x: amount, y: height / 2))

            context?.move(to: CGPoint(x: borderWidth, y: height / 2))
            context?.addArc(tangent1End: CGPoint(x: borderWidth, y: height - borderWidth), tangent2End: CGPoint(x: radius + borderWidth, y: height - borderWidth), radius: radius)
            context?.addLine(to: CGPoint(x: width - radius - borderWidth, y: height - borderWidth))

            angle = acos(x / radius)
            if angle.isNaN { angle = 0 }
            context?.addArc(center: CGPoint(x: width - radius - borderWidth, y: height / 2), radius: radius, startAngle: -CGFloat(Double.pi), endAngle: angle, clockwise: true)
            context?.addLine(to: CGPoint(x: amount, y: height / 2))

            context?.fillPath()

        } else if amount < radius + borderWidth, amount > 0 {
            context?.move(to: CGPoint(x: borderWidth, y: height / 2))
            context?.addArc(tangent1End: CGPoint(x: borderWidth, y: borderWidth), tangent2End: CGPoint(x: radius + borderWidth, y: borderWidth), radius: radius)
            context?.addLine(to: CGPoint(x: radius + borderWidth, y: height / 2))

            context?.move(to: CGPoint(x: borderWidth, y: height / 2))
            context?.addArc(tangent1End: CGPoint(x: borderWidth, y: height - borderWidth), tangent2End: CGPoint(x: radius + borderWidth, y: height - borderWidth), radius: radius)
            context?.addLine(to: CGPoint(x: radius + borderWidth, y: height / 2))

            context?.fillPath()
        }
        
    }
}
