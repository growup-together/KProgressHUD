//
//  KProgressHUD.swift
//  KProgressHUD
//
//  Created by raniys on 2019/5/5.
//  Copyright © 2019 kid17. All rights reserved.
//

import UIKit
import SnapKit

@objc public protocol KProgressHUDDelegate {
    @objc optional func hudWasHidden(hud: KProgressHUD)
}

public let KProgressMaxOffset: CGFloat = 1000000.0
public let KDefaultPadding: CGFloat = 4
public let KDefaultLabelFontSize: CGFloat = 16
public let KDefaultDetailsLabelFontSize: CGFloat = 12


/**
 * Displays a simple HUD window containing a progress indicator and two optional labels for short messages.
 *
 * This is a simple drop-in class for displaying a progress HUD view similar to Apple's private UIProgressHUD class.
 * The KProgressHUD window spans over the entire space given to it by the initWithFrame: constructor and catches all
 * user input on this region, thereby preventing the user operations on components below the view.
 *
 * @note To still allow touches to pass through the HUD, you can set hud.userInteractionEnabled = NO.
 * @attention KProgressHUD is a UI class and should therefore only be accessed on the main thread.
 * @note Swift implementation drops support for pre-ios7 and deprecated features from the KProgressHUD v1.0
 */
open class KProgressHUD: UIView {

    // MARK: - Properties
    
    /// The HUD delegate object. Receives HUD state notifications.
    public weak var delegate: KProgressHUDDelegate?
    
    /// Called after the HUD is hiden.
    public var completionBlock: (() -> Void)?
    
    /*
     * Grace period is the time (in seconds) that the invoked method may be run without
     * showing the HUD. If the task finishes before the grace time runs out, the HUD will
     * not be shown at all.
     * This may be used to prevent HUD display for very short tasks.
     * Defaults to 0 (no grace time).
     * @note The graceTime needs to be set before the hud is shown. You thus can't use `showHUDAddedTo:animated:`,
     * but instead need to alloc / init the HUD, configure the grace time and than show it manually.
     */
    public var graceTime: TimeInterval = 0
    
    /**
     * The minimum time (in seconds) that the HUD is shown.
     * This avoids the problem of the HUD being shown and than instantly hidden.
     * Defaults to 0 (no minimum show time).
     */
    public var minShowTime: TimeInterval = 0
    
    /**
     * Removes the HUD from its parent view when hidden.
     * Defaults to NO.
     */
    public var removeFromSuperViewOnHide: Bool = false
    
    /// KProgressHUD operation mode. The default is .indeterminate
    public var mode: KProgressHUDMode = .indeterminate { didSet { updateIndicators() } }
    
    /**
     * A color that gets forwarded to all labels and supported indicators. Also sets the tintColor
     * for custom views on iOS 7+. Set to nil to manage color individually.
     * Defaults to semi-translucent black on iOS 7 and later and white on earlier iOS versions.
     */
    public var contentColor: UIColor = UIColor(white: 0, alpha: 0.7) { didSet { updateView(for: contentColor) } }

    /// The animation type that should be used when the HUD is shown and hidden.
    public var animationType: KProgressHUDAnimation = .fade
    
    /**
     * The bezel offset relative to the center of the view. You can use KProgressMaxOffset
     * and -KProgressMaxOffset to move the HUD all the way to the screen edge in each direction.
     * E.g., CGPointMake(0.f, KProgressMaxOffset) would position the HUD centered on the bottom edge.
     */
    public var offset: CGPoint = CGPoint(x: 0, y: 0) { didSet { setNeedsUpdateConstraints() } }
    
    /**
     * The amount of space between the HUD edge and the HUD elements (labels, indicators or custom views).
     * This also represents the minimum bezel distance to the edge of the HUD view.
     * Defaults to 20.f
     */
    public var margin: CGFloat = 20 { didSet { setNeedsUpdateConstraints() } }
    
    /**
     *  The top and bottom margin of bezelView.
     *  Defaults to use margin for min value
     */
    public var bezelVectorialMargin: CGFloat? { didSet { setNeedsUpdateConstraints() } }
    
    /**
     *  The horizontal margin of bezelView.
     *  Defaults to use margin for min value
     */
    public var bezelHorizontalMargin: CGFloat? { didSet { setNeedsUpdateConstraints() } }
    

    /// The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
    public var minSize: CGSize = .zero { didSet { setNeedsUpdateConstraints() } }
    
    /// Force the HUD dimensions to be equal if possible.
    public var square: Bool = false { didSet { setNeedsUpdateConstraints() } }
    
    
    /// The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0.
    public var progress: CGFloat = 0 {
        didSet {
            indicator?.set(progress: progress)
        }
    }
    
    /// The Progress object feeding the progress information to the progress indicator.
    public var progressObject: Progress? { didSet { setProgressDisplayLink(enabled: true) } }
    
    /// The view containing the labels and indicator (or customView).
    private(set) public lazy var bezelView: HUDBackgroundView = {
        let view = HUDBackgroundView()
        view.layer.cornerRadius = 5
        view.alpha = 0
        return view
    }()
    
    /// View covering the entire HUD area, placed behind bezelView.
    private(set) public lazy var backgroundView: HUDBackgroundView = {
        let view = HUDBackgroundView(frame: bounds)
        view.style = .solidColor
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    /**
     * The UIView (e.g., a UIImageView) to be shown when the HUD is in KProgressHUDMode.customView.
     * The view should implement intrinsicContentSize for proper sizing. For best results use approximately 37 by 37 pixels.
     */
    public var customView: UIView? { didSet { updateIndicators() } }
    
    /**
     * A label that holds an optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
     * the entire text.
     */
    private(set) public var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: KDefaultLabelFontSize, weight: .medium)
        label.isOpaque = false
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    /// A label that holds an optional details message displayed below the labelText message. The details text can span multiple lines.
    private(set) public lazy var detailsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: KDefaultDetailsLabelFontSize, weight: .medium)
        label.isOpaque = false
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    /// A button that is placed below the labels. Visible only if a target / action is added.
    private(set) public lazy var actionButton: UIButton = {
        let button = HUDRoundedButton(type: .custom)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: KDefaultDetailsLabelFontSize, weight: .medium)
        return button
    }()
    
    
    // MARK: - Internal Properties
    
    var useAnimation: Bool = true
    var finished: Bool = false
    var indicator: UIView?
    var showStarted: Date?
    var paddingConstraints: [CGFloat]?
    var bezelConstraints: [CGFloat]?
    
    lazy var topSpacer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    lazy var bottomSpacer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var graceTimer: Timer?
    var minShowTimer: Timer?
    var hideDelayTimer: Timer?
    var progressObjectDisplayLink: CADisplayLink? {
        didSet { progressObjectDisplayLink?.add(to: .main, forMode: RunLoop.Mode.default) }
    }

    var hasFinished: Bool {
        return finished
    }
    
    // MARK: - Class methods
    
    public class func showAdded(to view: UIView, animated: Bool) -> KProgressHUD{
        let hud = KProgressHUD(with: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated: animated)
        return hud
    }
    
    public class func hide(for view: UIView, animated: Bool) -> Bool {
        guard let hud = HUD(for: view) else { return false }
        
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: animated)
        
        return true
    }
    
    public class func HUD(for view: UIView) -> KProgressHUD? {
        let subviewsEnum = view.subviews.reversed()
        
        let hud = subviewsEnum.first { (subView) -> Bool in
            guard
                let item = subView as? KProgressHUD,
                !item.hasFinished else { return false }
            return true
        }
        return hud as? KProgressHUD
    }
    
    // MARK: - Show & Hide
    
    public func show(animated: Bool) {
        minShowTimer?.invalidate()
        useAnimation = animated
        finished = false
        
        // If the grace time is set, postpone the HUD display
        if graceTime > 0 {
            let timer = Timer(timeInterval: graceTime, target: self, selector: #selector(handleGrace(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .common)
            graceTimer = timer
            
        } else { // ... otherwise show the HUD immediately
            showUsingAnimation(animated)
        }
    }
    
    public func hide(animated: Bool) {
        graceTimer?.invalidate()
        useAnimation = animated
        finished = true
        
        // If the minShow time is set, calculate how long the HUD was shown,
        // and postpone the hiding operation if necessary
        if minShowTime > 0, let startDate = showStarted {
            let interval = Date().timeIntervalSince(startDate)
            guard interval < minShowTime else { return }
            
            let timer = Timer(timeInterval: minShowTime - interval, target: self, selector: #selector(handleMinShow(_:)), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .common)
            minShowTimer = timer
            
        } else { // ... otherwise hide the HUD immediately
            hideUsingAnimation(animated)
        }
    }
    
    public func hide(animated: Bool, after delay: TimeInterval) {
        hideDelayTimer?.invalidate()
        
        let timer = Timer(timeInterval: delay, target: self, selector: #selector(handleHide(_:)), userInfo: animated, repeats: false)
        RunLoop.current.add(timer, forMode: .common)
        hideDelayTimer = timer
    }
    
    
    // MARK: - Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    convenience init(with view: UIView) {
        self.init(frame: view.bounds)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        updateForCurrentOrientation(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }
    
    func initialize() {
        // Transparent background
        isOpaque = false
        backgroundColor = UIColor.clear
        // Make it invisible for now
        alpha = 0
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        layer.allowsGroupOpacity = false
        
        configureViews()
        updateIndicators()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange(_:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }
    
    
    open override func layoutSubviews() {
        if !needsUpdateConstraints() {
            
        }
        super.layoutSubviews()
    }
    
    open override func updateConstraints() {
        
        bezelView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview().offset(offset.x)
            make.centerY.equalToSuperview().offset(offset.y)
            make.width.greaterThanOrEqualTo(minSize.width)
            make.height.greaterThanOrEqualTo(minSize.height)
            make.top.greaterThanOrEqualTo(margin)
            make.bottom.lessThanOrEqualTo(-margin)
            
            if let horizontalMargin = bezelHorizontalMargin {
                make.left.equalToSuperview().offset(horizontalMargin)
                make.right.equalToSuperview().offset(-horizontalMargin)
            } else {
                make.left.greaterThanOrEqualTo(margin)
                make.right.lessThanOrEqualTo(-margin)
            }
        }
        
        topSpacer.snp.remakeConstraints { (make) in
            if let vectorialMargin = bezelVectorialMargin {
                make.height.equalTo(vectorialMargin)
            } else {
                make.height.equalTo(margin)
            }
            make.top.left.right.equalToSuperview()
        }

        bottomSpacer.snp.remakeConstraints { (make) in
            make.height.equalTo(topSpacer.snp.height)
            make.bottom.left.right.equalToSuperview()
        }
        
        var subviews = [UIView]()
        if let indicator = indicator, !indicator.isHidden {
            subviews.append(indicator)
        }
        
        if !(titleLabel.text?.isEmpty ?? true), !titleLabel.isHidden {
            subviews.append(titleLabel)
        }

        if !(detailsLabel.text?.isEmpty ?? true), !detailsLabel.isHidden {
            subviews.append(detailsLabel)
        }

        if !(actionButton.title(for: .normal)?.isEmpty ?? true), !actionButton.isHidden {
            subviews.append(actionButton)
        }

        subviews.enumerated().forEach { (index, view) in
            view.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.left.greaterThanOrEqualTo(margin)
                make.right.lessThanOrEqualTo(-margin)

                if index == 0 {
                    make.top.equalTo(topSpacer.snp.bottom)
                    if subviews.count == 1 {
                        make.bottom.equalTo(bottomSpacer.snp.top)
                    }
                } else if index == subviews.count - 1 {
                    make.top.equalTo(subviews[index - 1].snp.bottom).offset(KDefaultPadding)
                    make.bottom.equalTo(bottomSpacer.snp.top)

                } else {
                    make.top.equalTo(subviews[index - 1].snp.bottom).offset(KDefaultPadding)
                }
            }
        }
    
        super.updateConstraints()
    }
    
    // MARK: - Configuration
    
    func configureViews() {
        addSubview(backgroundView)
        addSubview(bezelView)

        let defaultColor = contentColor
        titleLabel.textColor = defaultColor
        detailsLabel.textColor = defaultColor
        actionButton.setTitleColor(defaultColor, for: .normal)
        
        bezelView.addSubview(titleLabel)
        bezelView.addSubview(detailsLabel)
        bezelView.addSubview(actionButton)
        bezelView.addSubview(topSpacer)
        bezelView.addSubview(bottomSpacer)
    }
    
    func updateIndicators() {
        var indicator = self.indicator
        indicator?.removeFromSuperview()
        
        let isActivityIndicator = indicator is UIActivityIndicatorView
        let isRoundIndicator = indicator is HUDRoundProgressView
        
        switch mode {
        case .indeterminate:
            guard !isActivityIndicator else { return }
            let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
            indicatorView.startAnimating()
            bezelView.addSubview(indicatorView)
            indicator = indicatorView
            
        case .determinateHorizontalBar:
            let progressView = HUDBarProgressView()
            bezelView.addSubview(progressView)
            indicator = progressView
            
        case .determinate, .annularDeterminate:
            if !isRoundIndicator {
                let progressView = HUDRoundProgressView()
                bezelView.addSubview(progressView)
                indicator = progressView
            }
            
            if mode == .annularDeterminate,
                let progressView = indicator as? HUDRoundProgressView {
                progressView.annular = true
            }
            
        case .customView:
            guard
                customView != indicator,
                let customView = customView else { return }
            indicator = customView
            bezelView.addSubview(customView)
            
        case .text:
            indicator = nil
        }
        
        indicator?.set(progress: progress)
        
        self.indicator = indicator
        updateView(for: contentColor)
        setNeedsUpdateConstraints()
    }
    
    func updateView(for color: UIColor) {
        
        titleLabel.textColor = color
        detailsLabel.textColor = color
        actionButton.setTitleColor(color, for: .normal)
        
        guard let indicator = indicator else { return }
        
        if let indicatorView = indicator as? UIActivityIndicatorView {
            indicatorView.color = color
            
        } else if let indicatorView = indicator as? HUDRoundProgressView {
            indicatorView.progressTintColor = color
            indicatorView.backgroundTintColor = color.withAlphaComponent(0.1)
            
        } else if let indicatorView = indicator as? HUDBarProgressView {
            indicatorView.progressColor = color
            indicatorView.lineColor = color
            
        } else {
            if indicator.responds(to: NSSelectorFromString("setTintColor:")) {
                indicator.tintColor = color
            }
        }
        
    }
    
    // MARK: - Progress
    
    func setProgressDisplayLink(enabled: Bool) {
        guard
            enabled,
            let _ = progressObject,
            progressObjectDisplayLink == nil else {
            progressObjectDisplayLink?.invalidate()
            progressObjectDisplayLink = nil
            return
        }
        
        progressObjectDisplayLink = CADisplayLink(target: self, selector: #selector(updateProgressFromProgressObject))
    }
    
    @objc func updateProgressFromProgressObject() {
        progress = CGFloat(progressObject?.fractionCompleted ?? 0)
    }
    
    // MARK: - Timer
    
    @objc func handleGrace(_ timer: Timer) {
        guard !hasFinished else { return }
        showUsingAnimation(useAnimation)
    }
    
    @objc func handleMinShow(_ timer: Timer) {
        hideUsingAnimation(useAnimation)
    }
    
    @objc func handleHide(_ timer: Timer) {
        let animation = timer.userInfo as? Bool ?? false
        hide(animated: animation)
    }
}

// MARK: - Others

extension KProgressHUD {
    func showUsingAnimation(_ animated: Bool) {
        // Cancel any previous animations
        bezelView.layer.removeAllAnimations()
        backgroundView.layer.removeAllAnimations()
        
        // Cancel any scheduled hideAnimated:afterDelay: calls
        hideDelayTimer?.invalidate()
        
        showStarted = Date()
        alpha = 1
        
        // Needed in case we hide and re-show with the same Progress object attached.
        setProgressDisplayLink(enabled: true)
        
        if animated {
           animate(inAnimating: true, with: animationType)
        } else {
            bezelView.alpha = 1
            backgroundView.alpha = 1
        }
    }
    
    func hideUsingAnimation(_ animated: Bool) {
        // Cancel any scheduled hideAnimated:afterDelay: calls.
        // This needs to happen here instead of in done,
        // to avoid races if another hideAnimated:afterDelay:
        // call comes in while the HUD is animating out.
        
        hideDelayTimer?.invalidate()
        
        if animated, let _ = showStarted {
            showStarted = nil
            animate(inAnimating: false, with: animationType) { [weak self](finished) in
                self?.progressDone()
            }
        } else {
            showStarted = nil
            bezelView.alpha = 0
            backgroundView.alpha = 1
            progressDone()
        }
        
    }
    
    func animate(inAnimating: Bool, with type: KProgressHUDAnimation, completion: ((Bool) -> Void)? = nil) {
        // Automatically determine the correct zoom animation type
        var animationType = type
        if type == .zoom {
            animationType = inAnimating ? .zoomIn : .zoomOut
        }
        
        let small = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let large = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        
        // Set starting state
        if inAnimating, bezelView.alpha == 0, animationType == .zoomIn {
            bezelView.transform = small
        } else if inAnimating, bezelView.alpha == 0, animationType == .zoomOut {
            bezelView.transform = large
        }
        
        // Perform animations
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: {[weak self] in
            guard let self = self else { return }
            if inAnimating {
                self.bezelView.transform = .identity
            } else if inAnimating, animationType == .zoomIn {
                self.bezelView.transform = large
            } else if inAnimating, animationType == .zoomOut {
                self.bezelView.transform = small
            }
            
            let alpha: CGFloat = inAnimating ? 1 : 0
            self.bezelView.alpha = alpha
            self.backgroundView.alpha = alpha
            
        }, completion: completion)
    }
    
    
    @objc func statusBarOrientationDidChange(_ notification: Notification) {
        guard let _ = superview else { return }
        updateForCurrentOrientation(animated: true)
    }
    
    func updateForCurrentOrientation(animated: Bool) {
        if let superView = superview {
            frame = superView.bounds
        }
    }
    
    func progressDone() {
        setProgressDisplayLink(enabled: false)
        
        if hasFinished {
            alpha = 0
            
            if removeFromSuperViewOnHide {
                removeFromSuperview()
            }
        }
        
        completionBlock?()
        delegate?.hudWasHidden?(hud: self)
    }
}


extension UIView {
    
    func set(progress: CGFloat) {
        guard let indicator = self as? HUDProgressView else { return }
        indicator.progress = progress
    }
}
