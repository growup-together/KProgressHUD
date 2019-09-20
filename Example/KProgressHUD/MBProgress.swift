//
//  MBProgress.swift
//
//  Created by raniys on 9/20/16.
//  Copyright © 2016 raniys. All rights reserved.
//

import UIKit
import KProgressHUD


enum HUDProgressPosition {
    case top, middle, bottom
}

extension UIView {
    
    func showCustomView(_ customView: UIView,
                        message: String? = nil,
                        userInteractiion: Bool = false,
                        delay seconds: Float? = 2.0,
                        backColor: UIColor? = nil,
                        backgroundColor: UIColor? = UIColor(white: 0, alpha: 0.5),
                        contentColor: UIColor? = nil,
                        position: HUDProgressPosition? = .middle,
                        margin: CGFloat? = 0,
                        completion: (() -> Void)? = nil) {
        showProgress(message, userInteractiion: userInteractiion, delay: seconds, mode: .customView, customView: customView, backColor: backColor, backgroundColor: backgroundColor, contentColor: contentColor, position: position, margin: margin, completion: completion)
    }
    
    func showLabel(_ message: String,
                   userInteractiion: Bool = true,
                   backColor: UIColor = UIColor(white: 0, alpha: 0.7),
                   backgroundColor: UIColor? = UIColor.clear,
                   contentColor: UIColor = UIColor.white,
                   delay seconds: Float? = 2.0,
                   position: HUDProgressPosition? = .middle,
                   completion: (() -> Void)? = nil) {
        showProgress(message, userInteractiion: userInteractiion, delay: seconds, mode: .text, backColor: backColor, backgroundColor: backgroundColor, contentColor: contentColor, position: position, margin: 16, completion: completion)
    }
    
    func showProgress(_ message: String? = nil,
                      userInteractiion: Bool = false,
                      delay seconds: Float? = nil,
                      mode: KProgressHUDMode = .indeterminate,
                      customView: UIView? = nil,
                      backColor: UIColor? = nil,
                      backgroundColor: UIColor? = nil,
                      contentColor: UIColor? = nil,
                      position: HUDProgressPosition? = nil,
                      margin: CGFloat? = nil,
                      completion: (() -> Void)? = nil) {
        
        removeProgress()
        
        let hud = KProgressHUD.showAdded(to: self, animated: true)
        hud.isUserInteractionEnabled = !userInteractiion
        hud.mode = mode
        hud.completionBlock = {
            completion?()
        }
        
        if let msg = message {
            hud.titleLabel.text = msg
        }
        
        if let color = backColor {
            hud.bezelView.color = color
            hud.bezelView.style = .solidColor
        }
        
        if let color = backgroundColor {
            hud.backgroundView.color = color
            hud.backgroundView.style = .solidColor
        }
        
        if let color = contentColor {
            hud.contentColor = color
        }
        
        if let m = margin {
            hud.bezelVectorialMargin = m
            hud.bezelHorizontalMargin = m + 4
        }
        
        if let view = customView {
            hud.mode = .customView
            hud.customView = view
        }
        
        if let time = seconds {
            hud.hide(animated: true, after: Double(time))
        }
        
        if let pos = position {
            switch pos {
            case .top:
                hud.offset = CGPoint(x: 0.0, y: -150)
            case.bottom:
                hud.offset = CGPoint(x: 0.0, y: 150)
            default:
                hud.offset = CGPoint(x: 0.0, y: -50)
            }
        }

        if mode == .text {
            hud.bezelView.snp.updateConstraints { (make) in
                make.width.equalTo(self.bounds.width * (2.0 / 3.0)).priority(1000)
                make.center.equalToSuperview()
            }
        }
    }
    
    /// Hides other progresses
    func hideOthersforView(_ view: UIView, animated: Bool) {
        let huds = allProgressesforView(view)
        
        for hud in huds {
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated: animated)
        }
    }
    
    /// Get all the progresses for view
    func allProgressesforView(_ view: UIView) -> Array<KProgressHUD> {
        var huds = Array<KProgressHUD>()
        
        for sub in view.subviews {
            if sub.isKind(of: KProgressHUD.self) {
                huds.append(sub as! KProgressHUD)
            }
        }
        
        return huds
    }
    
    func removeProgress(_ animated: Bool = true) {
        let _ = KProgressHUD.hide(for: self, animated: animated)
    }
    
}
