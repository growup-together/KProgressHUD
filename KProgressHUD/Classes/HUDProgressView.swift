//
//  HUDProgressView.swift
//  KProgressHUD
//
//  Created by raniys on 2019/5/7.
//  Copyright © 2019 kid17. All rights reserved.
//

import UIKit

/// The parent progress view.
open class HUDProgressView: UIView {
    
    /// Progress (0.0 to 1.0)
    public var progress: CGFloat = 0 { didSet { setNeedsDisplay() } }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        isOpaque = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
