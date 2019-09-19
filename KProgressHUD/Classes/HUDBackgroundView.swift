//
//  HUDBackgroundView.swift
//  KProgressHUD
//
//  Created by raniys on 2019/5/5.
//  Copyright © 2019 kid17. All rights reserved.
//

import UIKit

open class HUDBackgroundView: UIView {
    
    /**
     * The background style.
     * Defaults to .blur.
     */
    public var style: KProgressHUDBackgroundStyle {
        set {
            guard newValue != _style else { return }
            _style = newValue
        }
        get { return _style }
    }
    
    /**
     * The blur effect style, when using KProgressHUDBackgroundStyle.blur.
     * Defaults to UIBlurEffectStyleLight.
     */
    public var blurEffectStyle: UIBlurEffect.Style {
        set {
            guard newValue != _blurEffectStyle else { return }
            _blurEffectStyle = newValue
        }
        get { return _blurEffectStyle }
    }

    /// The background color or the blur tint color.
    public var color: UIColor {
        set {
            guard newValue != _color else { return }
            _color = newValue
        }
        get { return _color }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        updateForBackgroundStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Smallest size possible. Content pushes against this.
    open override var intrinsicContentSize: CGSize { return .zero }
    
    private var _style: KProgressHUDBackgroundStyle = .blur { didSet { updateForBackgroundStyle() } }
    private var _blurEffectStyle: UIBlurEffect.Style = .light { didSet { updateForBackgroundStyle() } }
    private var _color: UIColor = UIColor(white: 0.8, alpha: 0.6) { didSet { updateViewsForColor() } }
    
    private var effectView: UIVisualEffectView?
    
    func updateForBackgroundStyle() {
        effectView?.removeFromSuperview()
        effectView = nil
        
        let style = _style
        if style == .blur {
            let effect = UIBlurEffect(style: _blurEffectStyle)
            let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = bounds
            effectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            
            insertSubview(effectView, at: 0)
            backgroundColor = _color
            layer.allowsGroupOpacity = false
            
            self.effectView = effectView
            
        } else {
            backgroundColor = _color
        }
    }
    
    func updateViewsForColor() {
        backgroundColor = _color
    }
}


