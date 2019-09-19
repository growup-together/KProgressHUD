//
//  Enums.swift
//  KProgressHUD
//
//  Created by raniys on 2019/5/5.
//  Copyright © 2019 kid17. All rights reserved.
//

import Foundation

public enum KProgressHUDMode: Int {
    /// UIActivityIndicatorView.
    case indeterminate
    /// A round, pie-chart like, progress view.
    case determinate
    /// Horizontal progress bar.
    case determinateHorizontalBar
    /// Ring-shaped progress view.
    case annularDeterminate
    /// Shows a custom view.
    case customView
    /// Shows only labels.
    case text
}

public enum KProgressHUDAnimation: Int {
    /// Opacity animation
    case fade
    /// Opacity + scale animation
    case zoom
    /// Opacity + scale animation (zoom out style)
    case zoomOut
    /// Opacity + scale animation (zoom in style)
    case zoomIn
}

public enum KProgressHUDBackgroundStyle: Int {
    /// Solid color background
    case solidColor
    /// UIVisualEffectView or UIToolbar.layer background view
    case blur
}
