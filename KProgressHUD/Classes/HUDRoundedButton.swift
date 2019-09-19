//
//  HUDRoundedButton.swift
//  KProgressHUD
//
//  Created by raniys on 2019/5/6.
//  Copyright © 2019 kid17. All rights reserved.
//

import UIKit

class HUDRoundedButton: UIButton {
    
    override var intrinsicContentSize: CGSize {
        guard allControlEvents != UIControl.Event(rawValue: 0) else { return .zero }
        
        var size = super.intrinsicContentSize
        size.width += 20
        
        return size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    override func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        super.setTitleColor(color, for: state)
        
        setHighlighted(isHighlighted)
        layer.borderColor = color?.cgColor
    }
    
    func setHighlighted(_ highlighted: Bool) {
        isHighlighted = highlighted
        
        let baseColor = titleColor(for: .selected)
        backgroundColor = highlighted ? baseColor?.withAlphaComponent(0.1) : UIColor.clear
    }
    
}
